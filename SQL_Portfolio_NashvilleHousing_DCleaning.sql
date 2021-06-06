USE PortfolioProject
--SELECT COUNT(*) FROM NashvilleHousing
--SELECT * FROM NashvilleHousing

--Standardizing Date Format
SELECT SaleDate, CAST(SaleDate AS Date)
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CAST(SaleDate AS Date)

ALTER TABLE NashvilleHousing
ADD SalesDateFormated Date;

UPDATE NashvilleHousing 
SET SalesDateFormated = CAST(SaleDate AS Date)


SELECT SaleDate , SalesDateFormated
FROM PortfolioProject..NashvilleHousing 

-- Populate Property Address Date
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, a.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
	JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.[PropertyAddress] IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking Down address into individual columns(Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing
-- Spliting the "PropertyAddress" String
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS City,
CHARINDEX(',',PropertyAddress )
FROM NashvilleHousing
-- Adding and updating the address column in the main df
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
-- Adding and updating the city column in the main df
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress 
FROM NashvilleHousing

--PARSENAME will also split the string but it replace the commas with the periods so we first we replace the comma with the period then split the string
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing

-- Now to add the breakdown of the OwnerAddress, I'll ALTER all the tables first then UPDATE them populating the address column in the main df
-- Adding the required columns by altering the main df
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),
    OwnerSplitCity Nvarchar(255),
    OwnerSplitState Nvarchar(255)
--Populating the new columns with the data in the main df
UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)

--Replacing 'Y' >> "YES" and 'N' >> "NO"
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	                    WHEN SoldAsVacant = 'N' THEN 'NO'
	                    ELSE SoldAsVacant
                   END
FROM NashvilleHousing

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num

FROM NashvilleHousing)
--ORDER BY ParcelID
DELETE 
FROM RowNumCTE  
WHERE row_num > 1

-- Delete specific columns from main df
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress , TaxDistrict, PropertyAddress, SaleDate
 
SELECT * FROM NashvilleHousing
-