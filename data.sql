USE [Netco_Database]
GO
/****** Object:  StoredProcedure [dbo].[CPN_spGetFullAddress]    Script Date: 9/29/2024 8:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[CPN_spGetFullAddress_V2]
(
	@Json		nvarchar(max),
	@ReturnMess nvarchar(max) output
)
AS
BEGIN
	Set @ReturnMess = '{"Location":'+
	(
		Select *
		From 
		(
			Select A.Code_Local Location_Code,A.Location_VN,A.Location_EN,
			B.Code_Local District_Code,B.District_VN,B.District_EN,
			C.Code_Local Wards_Code,C.Wards_VN,C.Wards_EN,
			C.Wards_VN + ',' + B.District_VN + ',' + A.Location_VN AddressFull, A.LocationId
			From
			(
				Select A.LocationId,A.Code_Local,A.Name Location_VN,dbo.non_unicode_convert(A.Name) Location_EN
				From Location(Nolock) A
				Where A.Type = 1
				And A.State = 0
			) A
			Left join
			(
				Select A.LocationId,A.Code_Local,A.Name District_VN,A.ParentId,dbo.non_unicode_convert(A.Name) District_EN
				From Location(Nolock) A
				Where A.Type = 2
				And A.State = 0
			) B On A.LocationId = B.ParentId
			Left join
			(
				Select A.LocationId,A.Code_Local,A.Name Wards_VN,A.ParentId,dbo.non_unicode_convert(A.Name) Wards_EN
				From Location(Nolock) A
				Where A.Type = 3
				And A.State = 0
			) C On B.LocationId = C.ParentId
		)A
	--	Order By A.Location_Code ASC
		For json auto
	)
	+ ',"Province":'+
	(
		Select A.LocationId as ProvinceId,A.Code_Local,A.Name as  Location_VN,dbo.non_unicode_convert(A.Name) Location_EN
		From Location(Nolock) A
		Where A.Type = 1
		And A.State = 0
		For json auto
	)
	+ ',"District":'+
	(
		Select A.LocationId As DistrictId, A.Code_Local,A.District_VN, A.ParentCode,A.ParentId, A.District_EN
		From 
		(
			Select A.LocationId, A.Code_Local,A.Name as  District_VN,  B.Code_Local ParentCode,B.LocationId as ParentId, dbo.non_unicode_convert(A.Name) District_EN
			From Location (Nolock) A
			left join Location (Nolock) B  on A.ParentId = B.LocationId And B.Type = 1
			Where A.Type = 2
			And A.State = 0
		) A
		For json auto
	)
	+ ',"Ward":'+
	(
		Select A.LocationId As WardId,A.Code_Local,A.Wards_VN, A.ParentCode, A.ParentId, A.Wards_EN
		From 
		(
			Select A.LocationId,A.Code_Local,A.Name as Wards_VN, B.Code_Local ParentCode, B.LocationId as ParentId, dbo.non_unicode_convert(A.Name) Wards_EN
			From Location(Nolock) A
			left join Location (Nolock) B  on A.ParentId = B.LocationId And B.Type = 2
			Where A.Type = 3
			And A.State = 0
		) A
		For json auto
	)+'}'
END


/*
Declare @Return nvarchar(max)
exec CPN_spGetFullAddress N'{}', @Return output

*/