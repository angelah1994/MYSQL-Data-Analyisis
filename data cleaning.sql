select * from PortfolioProject2..Nashvilehousing

select SaleDate, convert(Date, SaleDate)
from PortfolioProject2..Nashvilehousing

update Nashvilehousing
SET SaleDate = convert(Date, SaleDate)

Alter table Nashvilehousing
Add SaleDateConverted date

update Nashvilehousing
SET SaleDateConverted = convert(Date, SaleDate)

-- Populate property address

select *
from PortfolioProject2..Nashvilehousing
-- where PropertyAddress is null
order by parcelid


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
from PortfolioProject2..Nashvilehousing a
Join PortfolioProject2..Nashvilehousing b
on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null

update a 
SET propertyaddress = ISNULL(a.propertyAddress, b.propertyAddress)
from PortfolioProject2..Nashvilehousing a
Join PortfolioProject2..Nashvilehousing b
on a.parcelid = b.parcelid
and a.uniqueid != b.uniqueid
where a.propertyaddress is null


select * from PortfolioProject2..Nashvilehousing
where propertyaddress is null

-- Breaking out adress into individual columns
SELECT 
    -- Extract the part before the first comma
    SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) AS address_before_comma,

    -- Extract the part after the first comma
    LTRIM(SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))) AS address_after_comma

FROM 
    PortfolioProject2..Nashvilehousing;

Alter table Nashvilehousing
Add PropertysplitAddress nvarchar(255)

update Nashvilehousing
SET PropertysplitAddress =  SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1)

Alter table Nashvilehousing
Add PropertysplitCity nvarchar(255)

update Nashvilehousing
SET PropertysplitCity =  LTRIM(SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))) 

select 
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
FROM 
    PortfolioProject2..Nashvilehousing;

Alter table Nashvilehousing
Add ownersplitAddress nvarchar(255)

update Nashvilehousing
SET ownersplitAddress =  PARSENAME(replace(owneraddress, ',', '.'), 3)

Alter table Nashvilehousing
Add ownersplitCity nvarchar(255)

update Nashvilehousing
SET ownersplitCity =  PARSENAME(replace(owneraddress, ',', '.'),2)

Alter table Nashvilehousing
Add ownersplitstate nvarchar(255)

update Nashvilehousing
SET ownersplitState =  PARSENAME(replace(owneraddress, ',', '.'),1)


-- Change Y and N to yes and no in sold and vacant fild

Select distinct(soldAsvacant), count(soldAsvacant)
FROM 
    PortfolioProject2..Nashvilehousing
group by soldAsvacant
order by 2

select soldAsvacant,
case 
	when soldAsvacant = 'Y' Then 'Yes'
	when soldAsvacant = 'N' Then 'No'
	ElSE soldAsvacant 
END
FROM 
    PortfolioProject2..Nashvilehousing

update Nashvilehousing
SET soldAsVacant =  case 
	when soldAsvacant = 'Y' Then 'Yes'
	when soldAsvacant = 'N' Then 'No'
	ElSE soldAsvacant 
END

-- remove Duplicates
With row_numCTE as 
(
select * ,
	ROW_NUMBER () OVER(
	PARTITION BY parcelId, 
	propertyAddress, saledate,
	LegalReference
	order by uniqueid) As row_num
from PortfolioProject2..Nashvilehousing
-- order by parcelid
)
select * from row_numCTE
where row_num = 2

