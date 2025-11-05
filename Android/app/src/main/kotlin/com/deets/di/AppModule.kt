package com.deets.di

import android.content.Context
import androidx.room.Room
import com.deets.data.local.DeetsDatabase
import com.deets.data.repository.BusinessCardRepositoryImpl
import com.deets.domain.repository.BusinessCardRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt dependency injection module
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDeetsDatabase(
        @ApplicationContext context: Context
    ): DeetsDatabase {
        return Room.databaseBuilder(
            context,
            DeetsDatabase::class.java,
            DeetsDatabase.DATABASE_NAME
        )
            .fallbackToDestructiveMigration()
            .build()
    }

    @Provides
    @Singleton
    fun provideBusinessCardDao(database: DeetsDatabase) = database.businessCardDao()

    @Provides
    @Singleton
    fun provideBusinessCardRepository(
        repositoryImpl: BusinessCardRepositoryImpl
    ): BusinessCardRepository = repositoryImpl
}
