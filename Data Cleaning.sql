/*
Data Cleaning with Queries
*/

select * from
[dbo].[NashvilleHousing]

----------------------------------------------------------------------------------------------------

--Standardize Date Format

select Saledate,convert(date,Saledate) from
Portfolioproject..NashvilleHousing

Alter table NashvilleHousing
Add SalesdateConverted date

update NashvilleHousing
set SalesdateConverted=convert(date,Saledate)

----------------------------------------------------------------------------------------------------

--Populate Property address data

select Propertyaddress from
portfolioproject..nashvillehousing
where propertyaddress is null

select a.propertyaddress,b.propertyaddress,a.parcelid,b.parcelid,
ISNULL(b.propertyaddress,a.propertyaddress) as
Propertyaddressupdated from PortfolioProject..NashvilleHousing a
join
PortfolioProject..NashvilleHousing b
on	a.parcelid=b.parcelid
where a.propertyaddress is null
and a.uniqueid <> b.uniqueid

update a
set propertyaddress=ISNULL(b.propertyaddress,a.propertyaddress)
from PortfolioProject..NashvilleHousing a
	join PortfolioProject..NashvilleHousing b
	on	a.parcelid=b.parcelid
where a.propertyaddress is null
and a.uniqueid <> b.uniqueid

select propertyaddress from PortfolioProject..NashvilleHousing
where propertyaddress is null

----------------------------------------------------------------------------------------------------

--Breaking out address into each individual column

select SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as PropertySplitAddress,
SUBSTRING(propertyaddress,charindex(',',propertyaddress) +1,len(propertyaddress))
from PortfolioProject..
NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitedAddress nvarchar(255),PropertySplitCity nvarchar(255)


update Nashvillehousing
set PropertySplitedAddress =SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1),
PropertySplitCity = SUBSTRING(propertyaddress,charindex(',',propertyaddress) +1,len(propertyaddress)) 



select parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from portfolioproject..Nashvillehousing
order by 1 desc

Alter table NashvilleHousing
Add OwnerSplitedAddress nvarchar(255),OwnerSplitCity nvarchar(255),OwnerSplitState nvarchar(255)

update Nashvillehousing
set OwnerSplitedAddress =parsename(replace(owneraddress,',','.'),3),
OwnerSplitCity = parsename(replace(owneraddress,',','.'),2),
OwnerSplitState=parsename(replace(owneraddress,',','.'),1)

----------------------------------------------------------------------------------------------------

--Change Y to Yes and N to No in 'SoldAsVacant'

select distinct(Soldasvacant),count(soldasvacant) from Portfolioproject..NashvilleHousing
group by soldasvacant order by 2 desc
--where SoldAsVacant in('Y','N')

select Soldasvacant,
case when Soldasvacant ='Y' then 'Yes'
	 when Soldasvacant ='N' then 'No'
	 Else SoldAsVacant
	 end
from Portfolioproject..NashvilleHousing

update Nashvillehousing
set SoldAsVacant=case when Soldasvacant ='Y' then 'Yes'
	 when Soldasvacant ='N' then 'No'
	 Else SoldAsVacant
	 end

select * from Portfolioproject..NashvilleHousing

----------------------------------------------------------------------------------------------------

--Remove Duplicates
with RownumCTE as (
select*, 
	row_number() over (partition by ParcelId,
				PropertyAddress,
				Saleprice,SaleDate,
				LegalReference
				order by 
					uniqueid
			) row_num
from Portfolioproject..NashvilleHousing
)
delete from RownumCTE
where row_num >1

----------------------------------------------------------------------------------------------------

--Deleted Unused columns

alter table nashvillehousing
drop column PropertyAddress,SaleDate,TaxDistrict,Owneraddress

select * from Portfolioproject..NashvilleHousing

