package com.sharedeets.presentation.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sharedeets.domain.repository.BusinessCardRepository
import com.sharedeets.services.ExportService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File
import javax.inject.Inject

/**
 * ViewModel for Settings screen
 */
@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val repository: BusinessCardRepository,
    private val exportService: ExportService
) : ViewModel() {

    private val _uiState = MutableStateFlow<SettingsUiState>(SettingsUiState.Idle)
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    // Settings preferences (stored in DataStore in production)
    private val _syncEnabled = MutableStateFlow(false)
    val syncEnabled: StateFlow<Boolean> = _syncEnabled.asStateFlow()

    private val _notificationsEnabled = MutableStateFlow(true)
    val notificationsEnabled: StateFlow<Boolean> = _notificationsEnabled.asStateFlow()

    /**
     * Toggle sync setting
     */
    fun toggleSync(enabled: Boolean) {
        _syncEnabled.value = enabled
        // TODO: Implement Google Drive sync
    }

    /**
     * Toggle notifications
     */
    fun toggleNotifications(enabled: Boolean) {
        _notificationsEnabled.value = enabled
    }

    /**
     * Export all cards to VCF
     */
    fun exportAllToVCard() {
        viewModelScope.launch {
            _uiState.value = SettingsUiState.Processing

            // Get all cards
            repository.getAllCards().collect { cards ->
                if (cards.isEmpty()) {
                    _uiState.value = SettingsUiState.Error("No cards to export")
                    return@collect
                }

                val result = exportService.exportMultipleToVCard(cards)
                result.fold(
                    onSuccess = { file ->
                        _uiState.value = SettingsUiState.ExportReady(file)
                    },
                    onFailure = { error ->
                        _uiState.value = SettingsUiState.Error(
                            error.message ?: "Failed to export"
                        )
                    }
                )
            }
        }
    }

    /**
     * Export all cards to CSV
     */
    fun exportAllToCSV() {
        viewModelScope.launch {
            _uiState.value = SettingsUiState.Processing

            // Get all cards
            repository.getAllCards().collect { cards ->
                if (cards.isEmpty()) {
                    _uiState.value = SettingsUiState.Error("No cards to export")
                    return@collect
                }

                val result = exportService.exportToCSV(cards)
                result.fold(
                    onSuccess = { file ->
                        _uiState.value = SettingsUiState.ExportReady(file)
                    },
                    onFailure = { error ->
                        _uiState.value = SettingsUiState.Error(
                            error.message ?: "Failed to export"
                        )
                    }
                )
            }
        }
    }

    /**
     * Clear all data
     */
    fun clearAllData() {
        viewModelScope.launch {
            _uiState.value = SettingsUiState.Processing

            try {
                repository.deleteAllCards()
                _uiState.value = SettingsUiState.Success("All data cleared")
            } catch (e: Exception) {
                _uiState.value = SettingsUiState.Error(
                    e.message ?: "Failed to clear data"
                )
            }
        }
    }

    /**
     * Reset UI state
     */
    fun resetUiState() {
        _uiState.value = SettingsUiState.Idle
    }
}

/**
 * UI states for Settings screen
 */
sealed class SettingsUiState {
    data object Idle : SettingsUiState()
    data object Processing : SettingsUiState()
    data class Success(val message: String) : SettingsUiState()
    data class Error(val message: String) : SettingsUiState()
    data class ExportReady(val file: File) : SettingsUiState()
}
