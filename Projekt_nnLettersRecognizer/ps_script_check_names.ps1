# Ustaw ścieżkę do katalogu, w którym chcesz przeszukać pliki
$sciezkaDoKatalogu = "C:\Users\admin\Desktop\studia\Semestr 5\AO\projekt\typed-text-reader\Projekt_nnLettersRecognizer\images"

# Użyj Get-ChildItem do pobrania wszystkich plików w katalogu
$pliki = Get-ChildItem -Path $sciezkaDoKatalogu

# Iteruj przez każdy plik i sprawdź, czy nie zawiera znaku '_'
foreach ($plik in $pliki) {
    if ($plik.BaseName -notlike "*_*") {
        Write-Host "Plik bez znaku '_': $($plik.FullName)"
    }
}