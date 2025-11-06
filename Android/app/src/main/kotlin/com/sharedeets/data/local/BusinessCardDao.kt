package com.sharedeets.data.local

import androidx.room.*
import com.sharedeets.domain.model.BusinessCard
import kotlinx.coroutines.flow.Flow

/**
 * Data Access Object for BusinessCard entity
 */
@Dao
interface BusinessCardDao {

    @Query("SELECT * FROM business_cards ORDER BY dateScanned DESC")
    fun getAllCards(): Flow<List<BusinessCard>>

    @Query("SELECT * FROM business_cards WHERE id = :cardId")
    suspend fun getCardById(cardId: String): BusinessCard?

    @Query("SELECT * FROM business_cards WHERE id = :cardId")
    fun getCardByIdFlow(cardId: String): Flow<BusinessCard?>

    @Query("SELECT * FROM business_cards WHERE isFavorite = 1 ORDER BY dateScanned DESC")
    fun getFavoriteCards(): Flow<List<BusinessCard>>

    @Query("""
        SELECT * FROM business_cards
        WHERE fullName LIKE '%' || :query || '%'
           OR company LIKE '%' || :query || '%'
           OR email LIKE '%' || :query || '%'
           OR phoneNumber LIKE '%' || :query || '%'
           OR notes LIKE '%' || :query || '%'
        ORDER BY dateScanned DESC
    """)
    fun searchCards(query: String): Flow<List<BusinessCard>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCard(card: BusinessCard)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCards(cards: List<BusinessCard>)

    @Update
    suspend fun updateCard(card: BusinessCard)

    @Delete
    suspend fun deleteCard(card: BusinessCard)

    @Query("DELETE FROM business_cards WHERE id = :cardId")
    suspend fun deleteCardById(cardId: String)

    @Query("DELETE FROM business_cards")
    suspend fun deleteAllCards()

    @Query("SELECT COUNT(*) FROM business_cards")
    suspend fun getCardCount(): Int

    @Query("SELECT COUNT(*) FROM business_cards")
    fun getCardCountFlow(): Flow<Int>

    @Query("SELECT * FROM business_cards WHERE savedToContacts = 0")
    fun getUnsavedCards(): Flow<List<BusinessCard>>

    @Query("UPDATE business_cards SET savedToContacts = 1 WHERE id = :cardId")
    suspend fun markAsSavedToContacts(cardId: String)

    @Query("UPDATE business_cards SET isFavorite = :isFavorite WHERE id = :cardId")
    suspend fun updateFavoriteStatus(cardId: String, isFavorite: Boolean)

    @Query("UPDATE business_cards SET dateModified = :date WHERE id = :cardId")
    suspend fun updateModifiedDate(cardId: String, date: java.util.Date)
}
