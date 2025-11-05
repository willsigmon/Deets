package com.deets.presentation.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.deets.domain.model.BusinessCard
import com.deets.domain.repository.BusinessCardRepository
import com.deets.services.ContactsService
import com.deets.services.ExportService
import com.deets.util.PermissionManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.io.File
import javax.inject.Inject

/**
 * ViewModel for Card Detail screen
 * Mirrors iOS CardDetailView logic
 */
@HiltViewModel
class CardDetailViewModel @Inject constructor(
    private val repository: BusinessCardRepository,
    private val contactsService: ContactsService,
    private val exportService: ExportService,
    private val permissionManager: PermissionManager,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val cardId: String = checkNotNull(savedStateHandle["cardId"])

    val card: StateFlow<BusinessCard?> = repository.getCardById(cardId)
        .stateIn(viewModelScope, SharingStarted.Lazily, null)

    private val _uiState = MutableStateFlow<DetailUiState>(DetailUiState.Idle)
    val uiState: StateFlow<DetailUiState> = _uiState.asStateFlow()

    /**
     * Toggle favorite status
     */
    fun toggleFavorite() {
        viewModelScope.launch {
            card.value?.let { currentCard ->
                repository.updateFavoriteStatus(currentCard.id, !currentCard.isFavorite)
            }
        }
    }

    /**
     * Save to Android Contacts
     */
    fun saveToContacts() {
        viewModelScope.launch {
            _uiState.value = DetailUiState.Processing

            card.value?.let { currentCard ->
                if (!permissionManager.hasContactsPermission()) {
                    _uiState.value = DetailUiState.Error("Contacts permission required")
                    return@launch
                }

                val result = contactsService.saveBusinessCardToContacts(currentCard)
                result.fold(
                    onSuccess = {
                        repository.markAsSavedToContacts(currentCard.id)
                        _uiState.value = DetailUiState.Success("Saved to Contacts")
                    },
                    onFailure = { error ->
                        _uiState.value = DetailUiState.Error(
                            error.message ?: "Failed to save to contacts"
                        )
                    }
                )
            }
        }
    }

    /**
     * Export to vCard
     */
    fun exportToVCard() {
        viewModelScope.launch {
            _uiState.value = DetailUiState.Processing

            card.value?.let { currentCard ->
                val result = exportService.exportToVCard(currentCard)
                result.fold(
                    onSuccess = { file ->
                        _uiState.value = DetailUiState.ExportReady(file)
                    },
                    onFailure = { error ->
                        _uiState.value = DetailUiState.Error(
                            error.message ?: "Failed to export"
                        )
                    }
                )
            }
        }
    }

    /**
     * Delete card
     */
    fun deleteCard() {
        viewModelScope.launch {
            card.value?.let { currentCard ->
                repository.deleteCard(currentCard)
                _uiState.value = DetailUiState.Deleted
            }
        }
    }

    /**
     * Reset UI state
     */
    fun resetUiState() {
        _uiState.value = DetailUiState.Idle
    }
}

/**
 * UI states for Detail screen
 */
sealed class DetailUiState {
    data object Idle : DetailUiState()
    data object Processing : DetailUiState()
    data class Success(val message: String) : DetailUiState()
    data class Error(val message: String) : DetailUiState()
    data class ExportReady(val file: File) : DetailUiState()
    data object Deleted : DetailUiState()
}
