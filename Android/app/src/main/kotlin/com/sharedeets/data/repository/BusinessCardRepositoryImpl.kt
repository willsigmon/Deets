package com.sharedeets.data.repository

import com.sharedeets.data.local.BusinessCardDao
import com.sharedeets.domain.model.BusinessCard
import com.sharedeets.domain.repository.BusinessCardRepository
import kotlinx.coroutines.flow.Flow
import java.util.Date
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Implementation of BusinessCardRepository using Room database
 */
@Singleton
class BusinessCardRepositoryImpl @Inject constructor(
    private val dao: BusinessCardDao
) : BusinessCardRepository {

    override fun getAllCards(): Flow<List<BusinessCard>> {
        return dao.getAllCards()
    }

    override fun getCardById(cardId: String): Flow<BusinessCard?> {
        return dao.getCardByIdFlow(cardId)
    }

    override suspend fun getCardByIdOnce(cardId: String): BusinessCard? {
        return dao.getCardById(cardId)
    }

    override fun getFavoriteCards(): Flow<List<BusinessCard>> {
        return dao.getFavoriteCards()
    }

    override fun searchCards(query: String): Flow<List<BusinessCard>> {
        return dao.searchCards(query)
    }

    override fun getCardCount(): Flow<Int> {
        return dao.getCardCountFlow()
    }

    override fun getUnsavedCards(): Flow<List<BusinessCard>> {
        return dao.getUnsavedCards()
    }

    override suspend fun insertCard(card: BusinessCard) {
        dao.insertCard(card)
    }

    override suspend fun updateCard(card: BusinessCard) {
        val updatedCard = card.copy(dateModified = Date())
        dao.updateCard(updatedCard)
    }

    override suspend fun deleteCard(card: BusinessCard) {
        dao.deleteCard(card)
    }

    override suspend fun deleteCardById(cardId: String) {
        dao.deleteCardById(cardId)
    }

    override suspend fun deleteAllCards() {
        dao.deleteAllCards()
    }

    override suspend fun markAsSavedToContacts(cardId: String) {
        dao.markAsSavedToContacts(cardId)
        dao.updateModifiedDate(cardId, Date())
    }

    override suspend fun updateFavoriteStatus(cardId: String, isFavorite: Boolean) {
        dao.updateFavoriteStatus(cardId, isFavorite)
        dao.updateModifiedDate(cardId, Date())
    }
}
