package com.deets.presentation.preview

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.deets.domain.model.BusinessCard
import com.deets.domain.model.ParsedContact
import com.deets.domain.repository.BusinessCardRepository
import com.deets.services.ContactsService
import com.deets.util.PermissionManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Date
import javax.inject.Inject

/**
 * ViewModel for Contact Preview screen
 * Mirrors iOS ContactPreviewViewModel
 */
@HiltViewModel
class ContactPreviewViewModel @Inject constructor(
    private val repository: BusinessCardRepository,
    private val contactsService: ContactsService,
    private val permissionManager: PermissionManager
) : ViewModel() {

    private val _uiState = MutableStateFlow<PreviewUiState>(PreviewUiState.Editing)
    val uiState: StateFlow<PreviewUiState> = _uiState.asStateFlow()

    private val _parsedContact = MutableStateFlow<ParsedContact?>(null)
    val parsedContact: StateFlow<ParsedContact?> = _parsedContact.asStateFlow()

    // Editable fields
    private val _fullName = MutableStateFlow("")
    val fullName: StateFlow<String> = _fullName.asStateFlow()

    private val _jobTitle = MutableStateFlow("")
    val jobTitle: StateFlow<String> = _jobTitle.asStateFlow()

    private val _company = MutableStateFlow("")
    val company: StateFlow<String> = _company.asStateFlow()

    private val _email = MutableStateFlow("")
    val email: StateFlow<String> = _email.asStateFlow()

    private val _phoneNumber = MutableStateFlow("")
    val phoneNumber: StateFlow<String> = _phoneNumber.asStateFlow()

    private val _website = MutableStateFlow("")
    val website: StateFlow<String> = _website.asStateFlow()

    private val _notes = MutableStateFlow("")
    val notes: StateFlow<String> = _notes.asStateFlow()

    /**
     * Initialize with parsed contact
     */
    fun initialize(contact: ParsedContact) {
        _parsedContact.value = contact

        val fullName = listOfNotNull(contact.givenName, contact.familyName)
            .joinToString(" ")
        _fullName.value = fullName

        _jobTitle.value = contact.jobTitle ?: ""
        _company.value = contact.organizationName ?: ""
        _email.value = contact.emailAddresses.firstOrNull()?.address ?: ""
        _phoneNumber.value = contact.phoneNumbers.firstOrNull()?.number ?: ""
        _website.value = contact.urls.firstOrNull()?.url ?: ""
        _notes.value = contact.note ?: ""
    }

    /**
     * Update field values
     */
    fun updateFullName(value: String) {
        _fullName.value = value
    }

    fun updateJobTitle(value: String) {
        _jobTitle.value = value
    }

    fun updateCompany(value: String) {
        _company.value = value
    }

    fun updateEmail(value: String) {
        _email.value = value
    }

    fun updatePhoneNumber(value: String) {
        _phoneNumber.value = value
    }

    fun updateWebsite(value: String) {
        _website.value = value
    }

    fun updateNotes(value: String) {
        _notes.value = value
    }

    /**
     * Save business card to database
     */
    fun saveCard() {
        viewModelScope.launch {
            _uiState.value = PreviewUiState.Saving

            try {
                val card = BusinessCard(
                    fullName = _fullName.value,
                    jobTitle = _jobTitle.value.takeIf { it.isNotBlank() },
                    company = _company.value.takeIf { it.isNotBlank() },
                    email = _email.value.takeIf { it.isNotBlank() },
                    phoneNumber = _phoneNumber.value.takeIf { it.isNotBlank() },
                    website = _website.value.takeIf { it.isNotBlank() },
                    notes = _notes.value.takeIf { it.isNotBlank() },
                    rawText = _parsedContact.value?.rawText ?: "",
                    dateScanned = Date(),
                    dateModified = Date()
                )

                repository.insertCard(card)
                _uiState.value = PreviewUiState.Success(card)
            } catch (e: Exception) {
                _uiState.value = PreviewUiState.Error(
                    e.message ?: "Failed to save card"
                )
            }
        }
    }

    /**
     * Save card and add to contacts
     */
    fun saveCardAndAddToContacts() {
        viewModelScope.launch {
            _uiState.value = PreviewUiState.Saving

            try {
                val card = BusinessCard(
                    fullName = _fullName.value,
                    jobTitle = _jobTitle.value.takeIf { it.isNotBlank() },
                    company = _company.value.takeIf { it.isNotBlank() },
                    email = _email.value.takeIf { it.isNotBlank() },
                    phoneNumber = _phoneNumber.value.takeIf { it.isNotBlank() },
                    website = _website.value.takeIf { it.isNotBlank() },
                    notes = _notes.value.takeIf { it.isNotBlank() },
                    rawText = _parsedContact.value?.rawText ?: "",
                    dateScanned = Date(),
                    dateModified = Date(),
                    savedToContacts = true
                )

                // Save to database
                repository.insertCard(card)

                // Add to Android Contacts
                if (permissionManager.hasContactsPermission()) {
                    contactsService.saveBusinessCardToContacts(card)
                }

                _uiState.value = PreviewUiState.Success(card)
            } catch (e: Exception) {
                _uiState.value = PreviewUiState.Error(
                    e.message ?: "Failed to save card"
                )
            }
        }
    }

    /**
     * Validate form
     */
    fun isValid(): Boolean {
        return _fullName.value.isNotBlank() &&
                (_email.value.isNotBlank() || _phoneNumber.value.isNotBlank())
    }
}

/**
 * UI states for Preview screen
 */
sealed class PreviewUiState {
    data object Editing : PreviewUiState()
    data object Saving : PreviewUiState()
    data class Success(val card: BusinessCard) : PreviewUiState()
    data class Error(val message: String) : PreviewUiState()
}
