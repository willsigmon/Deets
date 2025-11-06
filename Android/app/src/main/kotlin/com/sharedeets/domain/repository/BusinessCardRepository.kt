package com.sharedeets.domain.repository

import com.sharedeets.domain.model.BusinessCard
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for BusinessCard operations
 */
interface BusinessCardRepository {
    fun getAllCards(): Flow<List<BusinessCard>>
    fun getCardById(cardId: String): Flow<BusinessCard?>
    suspend fun getCardByIdOnce(cardId: String): BusinessCard?
    fun getFavoriteCards(): Flow<List<BusinessCard>>
    fun searchCards(query: String): Flow<List<BusinessCard>>
    fun getCardCount(): Flow<Int>
    fun getUnsavedCards(): Flow<List<BusinessCard>>

    suspend fun insertCard(card: BusinessCard)
    suspend fun updateCard(card: BusinessCard)
    suspend fun deleteCard(card: BusinessCard)
    suspend fun deleteCardById(cardId: String)
    suspend fun deleteAllCards()
    suspend fun markAsSavedToContacts(cardId: String)
    suspend fun updateFavoriteStatus(cardId: String, isFavorite: Boolean)
}
