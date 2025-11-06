package com.sharedeets.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.sharedeets.domain.model.BusinessCard

/**
 * Main Room database for Deets app
 */
@Database(
    entities = [BusinessCard::class],
    version = 1,
    exportSchema = true
)
@TypeConverters(Converters::class)
abstract class DeetsDatabase : RoomDatabase() {
    abstract fun businessCardDao(): BusinessCardDao

    companion object {
        const val DATABASE_NAME = "deets_database"
    }
}
