package com.sharedeets.presentation.list

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sharedeets.domain.model.BusinessCard
import com.sharedeets.domain.repository.BusinessCardRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for Card List screen
 * Mirrors iOS CardListViewModel
 */
@HiltViewModel
class CardListViewModel @Inject constructor(
    private val repository: BusinessCardRepository
) : ViewModel() {

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _filterMode = MutableStateFlow(FilterMode.ALL)
    val filterMode: StateFlow<FilterMode> = _filterMode.asStateFlow()

    private val _sortMode = MutableStateFlow(SortMode.DATE_DESC)
    val sortMode: StateFlow<SortMode> = _sortMode.asStateFlow()

    // All cards from database
    private val allCards = repository.getAllCards()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // Filtered and sorted cards
    val cards: StateFlow<List<BusinessCard>> = combine(
        allCards,
        _searchQuery,
        _filterMode,
        _sortMode
    ) { cards, query, filter, sort ->
        var result = cards

        // Apply filter
        result = when (filter) {
            FilterMode.ALL -> result
            FilterMode.FAVORITES -> result.filter { it.isFavorite }
            FilterMode.UNSAVED -> result.filter { !it.savedToContacts }
        }

        // Apply search
        if (query.isNotBlank()) {
            result = result.filter { card ->
                card.searchableText.contains(query.lowercase())
            }
        }

        // Apply sort
        result = when (sort) {
            SortMode.DATE_DESC -> result.sortedByDescending { it.dateScanned }
            SortMode.DATE_ASC -> result.sortedBy { it.dateScanned }
            SortMode.NAME_ASC -> result.sortedBy { it.fullName.lowercase() }
            SortMode.NAME_DESC -> result.sortedByDescending { it.fullName.lowercase() }
        }

        result
    }.stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val cardCount = repository.getCardCount()
        .stateIn(viewModelScope, SharingStarted.Lazily, 0)

    /**
     * Update search query
     */
    fun updateSearchQuery(query: String) {
        _searchQuery.value = query
    }

    /**
     * Clear search query
     */
    fun clearSearch() {
        _searchQuery.value = ""
    }

    /**
     * Set filter mode
     */
    fun setFilterMode(mode: FilterMode) {
        _filterMode.value = mode
    }

    /**
     * Set sort mode
     */
    fun setSortMode(mode: SortMode) {
        _sortMode.value = mode
    }

    /**
     * Toggle favorite status
     */
    fun toggleFavorite(cardId: String, isFavorite: Boolean) {
        viewModelScope.launch {
            repository.updateFavoriteStatus(cardId, !isFavorite)
        }
    }

    /**
     * Delete card
     */
    fun deleteCard(card: BusinessCard) {
        viewModelScope.launch {
            repository.deleteCard(card)
        }
    }

    /**
     * Delete card by ID
     */
    fun deleteCardById(cardId: String) {
        viewModelScope.launch {
            repository.deleteCardById(cardId)
        }
    }

    /**
     * Delete all cards
     */
    fun deleteAllCards() {
        viewModelScope.launch {
            repository.deleteAllCards()
        }
    }
}

/**
 * Filter modes
 */
enum class FilterMode {
    ALL, FAVORITES, UNSAVED
}

/**
 * Sort modes
 */
enum class SortMode {
    DATE_DESC, DATE_ASC, NAME_ASC, NAME_DESC
}
