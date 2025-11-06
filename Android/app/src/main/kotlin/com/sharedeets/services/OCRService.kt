package com.sharedeets.services

import android.graphics.Bitmap
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Service for OCR text recognition using ML Kit
 * Equivalent to iOS VisionKit DataScanner
 */
@Singleton
class OCRService @Inject constructor() {

    private val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

    /**
     * Recognize text from image bitmap
     */
    suspend fun recognizeText(bitmap: Bitmap): Result<String> {
        return try {
            val image = InputImage.fromBitmap(bitmap, 0)
            val visionText = recognizer.process(image).await()

            val recognizedText = visionText.text
            if (recognizedText.isBlank()) {
                Result.failure(Exception("No text found in image"))
            } else {
                Result.success(recognizedText)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Recognize text with detailed block information
     */
    suspend fun recognizeTextWithBlocks(bitmap: Bitmap): Result<OCRResult> {
        return try {
            val image = InputImage.fromBitmap(bitmap, 0)
            val visionText = recognizer.process(image).await()

            val blocks = visionText.textBlocks.map { block ->
                TextBlock(
                    text = block.text,
                    boundingBox = block.boundingBox,
                    confidence = block.confidence ?: 0f,
                    lines = block.lines.map { line ->
                        TextLine(
                            text = line.text,
                            boundingBox = line.boundingBox,
                            confidence = line.confidence ?: 0f
                        )
                    }
                )
            }

            Result.success(
                OCRResult(
                    fullText = visionText.text,
                    blocks = blocks
                )
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Clean up resources
     */
    fun close() {
        recognizer.close()
    }
}

/**
 * OCR result with structured data
 */
data class OCRResult(
    val fullText: String,
    val blocks: List<TextBlock>
)

/**
 * Text block with metadata
 */
data class TextBlock(
    val text: String,
    val boundingBox: android.graphics.Rect?,
    val confidence: Float,
    val lines: List<TextLine>
)

/**
 * Text line with metadata
 */
data class TextLine(
    val text: String,
    val boundingBox: android.graphics.Rect?,
    val confidence: Float
)
