/* 

Cleaning Data in SQL Queries

*/

SELECT * FROM PortfolioProject..Nashville


---- Standardize Date Format

ALTER TABLE PortfolioProject..Nashville
ADD SaleDateConverted Date

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted FROM PortfolioProject..Nashville


----Populate Property Address Data

SELECT *
FROM PortfolioProject..Nashville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID, NashB.PropertyAddress, ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
FROM PortfolioProject..Nashville NashA 
JOIN PortfolioProject..Nashville NashB
	ON NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ] <> NashB.[UniqueID ]
WHERE NashA.PropertyAddress IS NULL

UPDATE NashA
SET PropertyAddress = ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
FROM PortfolioProject..Nashville NashA 
JOIN PortfolioProject..Nashville NashB
	ON NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ] <> NashB.[UniqueID ]
WHERE NashA.PropertyAddress IS NULL


---- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..Nashville

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..Nashville
ADD PropertySplitCity NVARCHAR(255)

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM PortfolioProject..Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitAddress NVARCHAR(255)
GO

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
GO

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitCity NVARCHAR(255)
GO

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
GO

ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitState NVARCHAR(255)
GO

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
GO

---- Change Y and N to Yes amd No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville
GROUP BY SoldAsVacant
ORDER BY 2


SELECT  SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..Nashville


---- Remove Duplicates

WITH RowNumCTE AS(
SELECT  *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 )row_num
FROM PortfolioProject..Nashville
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

/*
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
*/


---- Delete Unused Columns

ALTER TABLE PortfolioProject..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * FROM PortfolioProject..Nashville