/*
Cleaning Data in SQL Queries
*/


select * 
from NashvilleHousing

select SaleDateConverted,convert(Date,SaleDate)
from NashvilleHousing


-- Standardize Date Format
select SaleDate,convert(Date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate= Convert(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted= Convert(Date,SaleDate)


--------------------------
---- Populate Property Address data
select * 
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

---self- join
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.UniqueID <>b.UniqueID
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select 
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from NashvilleHousing 

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress= SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity= SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))

select PropertyAddress,PropertySplitAddress,PropertySplitCity
from NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add 
OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255)

update NashvilleHousing
set 
OwnerSplitAddress= PARSENAME(replace(OwnerAddress,',','.'),3),
OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2),
OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)



--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case 
     when SoldAsVacant='Y' THEN 'Yes'
	 when SoldAsVacant='N' THEN 'No'
	 else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant= 
case 
     when SoldAsVacant='Y' THEN 'Yes'
	 when SoldAsVacant='N' THEN 'No'
	 else SoldAsVacant
end



-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
with rnCTE AS(
select *,
Row_number() over(
partition by ParcelID,
             PropertyAddress,
			 SaleDate,
			 salePrice,
			 LegalReference
order by UniqueID
) rn
from NashvilleHousing)

select *
from rnCTE
where rn>1

--delete
--from rnCTE
--where rn>1



---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

alter table NashvilleHousing
drop column OwnerAdress

