package com.sharedeets.presentation.scanner

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sharedeets.domain.model.ParsedContact
import com.sharedeets.services.ContactParserService
import com.sharedeets.services.OCRService
import com.sharedeets.util.PermissionManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for Scanner screen
 * Mirrors iOS ScanViewModel
 */
@HiltViewModel
class ScannerViewModel @Inject constructor(
    private val ocrService: OCRService,
    private val parserService: ContactParserService,
    private val permissionManager: PermissionManager
) : ViewModel() {

    private val _uiState = MutableStateFlow<ScannerUiState>(ScannerUiState.Idle)
    val uiState: StateFlow<ScannerUiState> = _uiState.asStateFlow()

    private val _parsedContact = MutableStateFlow<ParsedContact?>(null)
    val parsedContact: StateFlow<ParsedContact?> = _parsedContact.asStateFlow()

    /**
     * Process captured image with OCR and parsing
     */
    fun processImage(bitmap: Bitmap) {
        viewModelScope.launch {
            _uiState.value = ScannerUiState.Processing

            // Step 1: OCR
            val ocrResult = ocrService.recognizeText(bitmap)

            ocrResult.fold(
                onSuccess = { text ->
                    // Step 2: Parse contact info
                    val parsed = parserService.parseContact(text)
                    _parsedContact.value = parsed

                    if (parsed.isValidForSaving) {
                        _uiState.value = ScannerUiState.Success(parsed)
                    } else {
                        _uiState.value = ScannerUiState.Error("Could not extract valid contact information")
                    }
                },
                onFailure = { error ->
                    _uiState.value = ScannerUiState.Error(
                        error.message ?: "Failed to recognize text"
                    )
                }
            )
        }
    }

    /**
     * Reset to idle state
     */
    fun reset() {
        _uiState.value = ScannerUiState.Idle
        _parsedContact.value = null
    }

    /**
     * Check camera permission
     */
    fun hasCameraPermission(): Boolean {
        return permissionManager.hasCameraPermission()
    }
}

/**
 * UI states for Scanner screen
 */
sealed class ScannerUiState {
    data object Idle : ScannerUiState()
    data object Processing : ScannerUiState()
    data class Success(val parsedContact: ParsedContact) : ScannerUiState()
    data class Error(val message: String) : ScannerUiState()
}
