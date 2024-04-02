/*

Cleaning Data in Sql Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date,SaleDate)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)


-------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




-------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual columns (Address, City, State)
 

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID

Select
propertyaddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),len(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),len(PropertyAddress))


Select *
from PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

--Another way to split text

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

Select *
from PortfolioProject.dbo.NashvilleHousing



-------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
	When soldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When soldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

Select *
from PortfolioProject.dbo.NashvilleHousing



-------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with RowNumCTE as (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)



select *
from RowNumCTE
where row_num > 1

--Delete
--from RowNumCTE
--where row_num > 1




-------------------------------------------------------------------------------------------------------------------
-- Delete unused columns

Select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress


alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate