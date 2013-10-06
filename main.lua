
local myname, ns = ...

local Kintama = LibStub('AceAddon-3.0'):NewAddon('Kintama', 'AceHook-3.0', 'AceEvent-3.0', 'AceConsole-3.0', 'AceBucket-3.0')

function Kintama:OnInitialize()
	self.column_width = 39
	self.row_height = 39
	self.top_border = 8
	self.bottom_border = 24
	self.right_border = 5
	self.left_border = 8

	self.frame = ns.NewMainFrame('KintamaFrame', self)
	self.frame:SetPoint("BOTTOMRIGHT", UIParent, -50, 175)
	self.frame:SetHeight(5 * 39 + self.bottom_border + self.top_border)
	self.frame:SetBackdropColor(0,0,0, 0.65)
	self.frame:SetFrameStrata('MEDIUM')

	for bag_id=0,4 do
		ns.MakeBagFrame(bag_id, self.frame)
	end
	ns.MakeBagFrame = nil

	BagItemSearchBox:Hide()
	BagItemSearchBox.Show = BagItemSearchBox.Hide
end

function Kintama:OnEnable()
	self:RawHook("ToggleBag", true)
	self:RawHook("ToggleBackpack", "ToggleBag", true)
	self:RawHook("ToggleAllBags", "ToggleBag", true)
	self:RawHook("OpenBag", true)
	self:RawHook("CloseBag", true)

	local open = function()
		if not self.frame:IsVisible() then
			self:OpenBag()
		end
	end

	local close = function(event)
		self:CloseBag()
	end

	self:RegisterEvent("AUCTION_HOUSE_SHOW",  open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED",  close)
	self:RegisterEvent("BANKFRAME_OPENED",  open)
	self:RegisterEvent("BANKFRAME_CLOSED",  close)
	self:RegisterEvent("MAIL_SHOW",   open)
	self:RegisterEvent("MAIL_CLOSED",     close)
	self:RegisterEvent("MERCHANT_SHOW",   open)
	self:RegisterEvent("MERCHANT_CLOSED",   close)
	self:RegisterEvent("TRADE_SHOW",    open)
	self:RegisterEvent("TRADE_CLOSED",    close)
	self:RegisterEvent("GUILDBANKFRAME_OPENED", open)
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", close)
end

--[[************************************************************************************************
-- Bag methods
**************************************************************************************************]]
function Kintama:OrganizeBagSlots()
	local widest_column = 0

	for bag=0,4 do
		local f = ns.bags[bag]
		f:Update()
		widest_column = math.max(widest_column, ns.bags[bag]:GetWidth())
	end

	self.frame:SetWidth(widest_column + self.left_border + self.right_border)
end


--[[************************************************************************************************
-- Event Handlers
**************************************************************************************************]]
function Kintama:ToggleBag(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return self.hooks.ToggleBag(bag_id)
	end

	if self.frame:IsVisible() then
		self:CloseBag()
	else
		self:OpenBag()
	end
end

function Kintama:OpenBag(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return self.hooks.OpenBag(bag_id)
	end

	self.frame:Show()
end

function Kintama:CloseBag(bag_id)
	if type(bag_id) == "number" and (bag_id < 0 or bag_id > 4) then
		return self.hooks.CloseBag(bag_id)
	end

	self.frame:Hide()
end

function Kintama:UpdateAllBags()
	self:OrganizeBagSlots()
end

function Kintama:UpdateBags(bag_ids)
	self:OrganizeBagSlots()
end


--[[************************************************************************************************
-- Frame delegates
**************************************************************************************************]]
function Kintama:OnShow(frame)
	self:UpdateAllBags()

	self.bag_update_bucket = self:RegisterBucketEvent('BAG_UPDATE', .1, 'UpdateBags')

	self:RegisterEvent('BAG_UPDATE_COOLDOWN', 'UpdateAllBags')
	self:RegisterEvent('UPDATE_INVENTORY_ALERTS', 'UpdateAllBags')
end

function Kintama:OnHide(frame)
	self:UnregisterBucket(self.bag_update_bucket)

	self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
	self:UnregisterEvent('UPDATE_INVENTORY_ALERTS')

	self:CloseBag() -- internal cleanup
end
