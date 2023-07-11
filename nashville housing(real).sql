


--Figuring out the date in DD/MM/YYYY format
select * from nashvillehousing
select SaleDate,CONVERT(date,SaleDate) from nashvillehousing


--Eliminating duplicate values in address 
select a.OwnerName,a.PropertyAddress,b.PropertyAddress,a.OwnerName,ISNULL(a.PropertyAddress,b.PropertyAddress) from nashvillehousing a 
join nashvillehousing b
on a.OwnerName=b.OwnerName
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set propertyaddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashvillehousing a 
join nashvillehousing b
on a.OwnerName=b.OwnerName
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking up address into country, city
select 
substring(Propertyaddress,1, charindex(',',propertyaddress)-1) as address,
substring(Propertyaddress, charindex(',',propertyaddress) +1 ,len(propertyaddress)) as address
from nashvillehousing

alter table nashvillehousing
add propertysplitaddress nvarchar(250)

update nashvillehousing
set propertysplitaddress = substring(Propertyaddress,1, charindex(',',propertyaddress)-1) 

alter table nashvillehousing
add propertysplitcity nvarchar(250)

update nashvillehousing
set propertysplitcity = substring(Propertyaddress, charindex(',',propertyaddress) +1 ,len(propertyaddress))

--Another way to separate (owner) address into different parts. 

select parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1) from nashvillehousing

alter table nashvillehousing
add ownersplitaddress nvarchar(250)

update nashvillehousing
set ownersplitaddress = parsename(replace(owneraddress,',','.'),3)

alter table nashvillehousing
add ownersplitcity nvarchar(250)

update nashvillehousing
set ownersplitcity = parsename(replace(owneraddress,',','.'),2)

alter table nashvillehousing
add ownersplitstate nvarchar(250)

update nashvillehousing
set ownersplitstate = parsename(replace(owneraddress,',','.'),1)

select * from nashvillehousing

--Removing Y and N to replace with Yes and No

select distinct(soldasvacant) from nashvillehousing

select soldasvacant, 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
from nashvillehousing

update nashvillehousing
set SoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
from nashvillehousing

--Deleting duplicate values by making a CTE Table

with ctetable as (
select *,
 row_number() over (
 partition by parcelID,
 Propertyaddress,
 SalePrice,
 SaleDate,
 LegalReference
 Order by uniqueID) row_num
 from nashvillehousing
 )
 select * from ctetable

--Delete unused columns

select * from nashvillehousing

alter table nashvillehousing
drop column Taxdistrict




















