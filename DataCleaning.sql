-------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------/* Cleaning data in SQL*/-------------------------------------------------------------------------------------------------------
Select *
from Portfolioproject..Housing
-------------------------------------------------------------------------------------------------------------------------------------------------------------
----Standardising Date format
Select SaleDate, CONVERT(Date,SaleDate)
From Portfolioproject..Housing

Update Housing
SET SaleDate = CONVERT(Date,SaleDate)

---If it doesn't Update properly

ALTER TABLE Housing
Add Sale_Date Date;

Update Housing
SET Sale_Date = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populating the property address column using parcel ID as a reference
Select *
from Portfolioproject..Housing 
where PropertyAddress is null
order by ParcelID

--using a Self join to populate data
select X.[UniqueID ], X.ParcelID, X.PropertyAddress, Y.[UniqueID ], Y.ParcelID, Y.PropertyAddress
from Portfolioproject..Housing X JOIN Portfolioproject..Housing Y
on X.ParcelID = Y.ParcelID AND X.[UniqueID ] <> Y.[UniqueID ]
where X.PropertyAddress is null

Update X 
SET PropertyAddress = ISNULL(X.PropertyAddress,Y.PropertyAddress)
from Portfolioproject..Housing X JOIN Portfolioproject..Housing Y
on X.ParcelID = Y.ParcelID AND X.[UniqueID ] <> Y.[UniqueID ]
where X.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Splitting owner address into 3 columns (adress,city,state) for easier data manipulation
select OwnerAddress
from Portfolioproject..Housing

Select 
PARSENAME(replace(OwnerAddress,',','.'),1),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),3)
from Portfolioproject..Housing

ALTER TABLE Housing
Add Owner_adress Nvarchar(255), Owner_cityadress Nvarchar(255), Owner_stateadress Nvarchar(255)

Update Housing
SET Owner_adress = PARSENAME(replace(OwnerAddress,',','.'),3),
	Owner_cityadress = PARSENAME(replace(OwnerAddress,',','.'),2), 
	Owner_stateadress = PARSENAME(replace(OwnerAddress,',','.'),1)

---- Splititing Property adress into 2 columns (adress,city)
select PropertyAddress
from Portfolioproject..Housing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1), SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))
from Portfolioproject..Housing

ALTER TABLE Housing
Add Propety_adress Nvarchar(255), Property_cityadress Nvarchar(255)

Update Housing
SET Propety_adress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	Property_cityadress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------------------------------------------
Select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Portfolioproject..Housing
group by SoldAsVacant
order by COUNT(SoldAsVacant)
--running the above query shows Yes,No,Y and N populated in the sold as vacant plot therefore changing the Y and N to Yes and No in the SoldAsVacant column--
Update Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	 WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
	 END
from Portfolioproject..Housing
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Removing duplicates

WITH rownum_CTE as 
(
Select *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
			Order by [UniqueID ]) row_num
from Portfolioproject..Housing
)
DELETE
from rownum_CTE
Where row_num > 1

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Deleting unused columns Saleddate,Owneraddress and Propertyadress

ALTER TABLE Portfolioproject..Housing
DROP COLUMN SaleDate,OwnerAddress,PropertyAddress

-------------------------------------------------------------------------------------------------------------------------------------------------------------
