--1)Standardized date format
SELECT SaleDateConverted, CONVERT(Date,SaleDate) FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------------
--2)Populated/Join same property address columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

--There are few same parcelID with different UniqueID that we gonna join together 

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Then check back the Property Address should be everything is not null already

----------------------------------------------------------------------------------------
--3) Breaking out  Pproperty Address into Individual Column (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVarChar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVarChar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--for checking wheteher the additional column updated or not

----------------------------------------------------------------------------------------
--4) Breaking out  Owner Address into Individual Column (Address, City, State) by using ParseName


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------
--5)Change Y and N to Yes and No in "Sold as Vacant" Column

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
--to check how many inconsistency of Y and N have

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant 
	 END

------------------------------------------------------------------------------
--6)Remove duplicate

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Check parcelID or SaleDate or PropertyAddress or SalePrice or LegalReference is same
--Partition is to check the row is unique between each column

--SELECT *,
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,
--				 PropertyAddress,
--				 SalePrice,
--				 SaleDate,
--				 LegalReference
--	ORDER BY UniqueID) Row_Num
--FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) Row_Num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress
--This is all the duplicate row


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) Row_Num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1
--this is to delete the duplicate row
--then check back the select all duplicate number to check whether already deleted or not



------------------------------------------------------------------------------
--7)Delete unused column (PropertyAddress, OwnerAddress, SaleDate, TaxDistrict)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict