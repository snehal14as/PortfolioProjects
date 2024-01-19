/* 
****
Cleaning Data in SQL
****
*/

select * from NashvilleHousing



/*

**** Standardise Date format ****

*/
select SaleDateConverted, convert(date, SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

ALTER Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


/*

**** Populate Property Address area ****

*/
select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- Data has some Property Address columns as NULL
-- Joining the same tables with each other to identify same ParcelID but different UnqiueID
-- Hence filling out "NULL" Property Address using ISNULL() function
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Checking if there are any remaining NULL values
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into individual columns as Address, City, State
select PropertyAddress 
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from NashvilleHousing
/* Above Output
Address
3806  FAIRVIEW DR,
3804  FAIRVIEW DR,
4005  CEDAR CIR,
4008 CEDAR  CIR,
4002  CEDAR CIR,
4013  MEADOW RD,
4006  MEADOW RD,
3721  FAIRVIEW DR,
3602  W HAMILTON RD,
3602  W HAMILTON RD,
3902 MEADOW  RD,
and so on ..
*/

-- Since the output is showing , as well hence we will remove the , by using -1
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing

-- Looking at Owner Address
-- Splitting Owner Address
select OwnerAddress
from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing


/*

**** Change Y and N to Yes and No in "Sold as Vacant" field ****

*/
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
set 
SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


/*

**** Remove Duplicates ****

*/
-- Finding out duplicates
WITH RowNumCTE as (
select *,
	ROW_NUMBER() OVER (
	Partition by 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference 
		Order by 
			UniqueID
		) row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- Deleting duplicates
WITH RowNumCTE as (
select *,
	ROW_NUMBER() OVER (
	Partition by 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate, 
		LegalReference 
		Order by 
			UniqueID
		) row_num
from NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1


/*

**** Delete unused columns ****

*/
select * 
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate