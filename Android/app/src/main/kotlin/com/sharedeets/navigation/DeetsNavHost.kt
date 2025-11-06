package com.sharedeets.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.sharedeets.presentation.detail.CardDetailScreen
import com.sharedeets.presentation.list.CardListScreen
import com.sharedeets.presentation.preview.ContactPreviewScreen
import com.sharedeets.presentation.scanner.ScannerScreen
import com.sharedeets.presentation.settings.SettingsScreen

/**
 * Navigation routes
 */
object Routes {
    const val CARD_LIST = "card_list"
    const val SCANNER = "scanner"
    const val PREVIEW = "preview"
    const val DETAIL = "detail/{cardId}"
    const val SETTINGS = "settings"

    fun detail(cardId: String) = "detail/$cardId"
}

/**
 * Main navigation host
 */
@Composable
fun DeetsNavHost(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController(),
    startDestination: String = Routes.CARD_LIST
) {
    NavHost(
        navController = navController,
        startDestination = startDestination,
        modifier = modifier
    ) {
        composable(Routes.CARD_LIST) {
            CardListScreen(
                onNavigateToScanner = { navController.navigate(Routes.SCANNER) },
                onNavigateToDetail = { cardId ->
                    navController.navigate(Routes.detail(cardId))
                },
                onNavigateToSettings = { navController.navigate(Routes.SETTINGS) }
            )
        }

        composable(Routes.SCANNER) {
            ScannerScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToPreview = { navController.navigate(Routes.PREVIEW) }
            )
        }

        composable(Routes.PREVIEW) {
            ContactPreviewScreen(
                onNavigateBack = { navController.popBackStack() },
                onSaveSuccess = {
                    // Navigate back to list and clear back stack
                    navController.navigate(Routes.CARD_LIST) {
                        popUpTo(Routes.CARD_LIST) { inclusive = true }
                    }
                }
            )
        }

        composable(
            route = Routes.DETAIL,
            arguments = listOf(navArgument("cardId") { type = NavType.StringType })
        ) {
            CardDetailScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Routes.SETTINGS) {
            SettingsScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
