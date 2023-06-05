SELECT *
FROM NationalHousing


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NationalHousing

Alter Table NationalHousing
Alter Column SaleDate date

--JOINING SAME TABLE TO IDENTIFY DATA FOR CLEANING----
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NationalHousing a
JOIN NationalHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL

-- POPULATION EMPTY PropertyAddress COLUMN FROM OTHER COLUMNS WITH SAME Parcelid----
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NationalHousing a
JOIN NationalHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL



--SPLITTING ADDRESS AND CITY FROM PropertyAdress COLUMN USING 'SUBSTRING'--
ALTER TABLE NationalHousing
ADD PropertySplitAdress nvarchar(255);

UPDATE NationalHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NationalHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


----SPLITTING ADDRESS, CITY AND STATE FROM OwnerAdress COLUMN USING 'PARSENAME'--
ALTER TABLE NationalHousing
ADD OwnerSplitAdress nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NationalHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NationalHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--REGULARIZING SoldAsVacant COLUMN TO HAVE SIMILAR ENTRY FORMAT----
Update NationalHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
					END


--CHECKING THE RESULT OF REGULARIZATION--
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NationalHousing
Group by SoldAsVacant
Order by 2


--DELETING DUPLICATE DATA USING CTE AND PARTITION BY--
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
)Row_num
FROM NationalHousing
)
DELETE
FROM RowNumCTE
Where Row_num > 1

--DELETING UNUSED COLUMNS--
ALTER TABLE NationalHousing
Drop Column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
