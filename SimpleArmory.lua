--  SimpleArmory Helper Addon (by Marko)
--
local toJSON = newencoder(); -- initialize json encoder
local _, SimpleArmory = ...

SimpleArmory = LibStub("AceAddon-3.0"):NewAddon(
    SimpleArmory, "SimpleArmory", "AceConsole-3.0",
    "AceEvent-3.0"
)

function SimpleArmory:OnInitialize()
    SimpleArmory:RegisterChatCommand('sa', 'ParseCommand')
    SimpleArmory:RegisterChatCommand('simplearmory', 'ParseCommand')
    SimpleArmory:RegisterChatCommand('rl', 'ReloadUI') -- elvui provides this, but I load only this addon while developing and its nice to have

    -- SimpleArmory:ShowInFrame(SimpleArmory:GetAllMyMounts())
end

function SimpleArmory:OnDisable()
end

function SimpleArmory:ReloadUI()
    ReloadUI()
end

function SimpleArmory:ParseCommand(args)
    local command, commandArg1, commandArg2 = self:GetArgs(args, 3)
    if not command then
        SimpleArmory:PrintUsage()
    else
        if command == "toys" then
            SimpleArmory:ShowInFrame(SimpleArmory:ExportToys())
        elseif command == "dev" then
            if commandArg1 == "mounts" then
                SimpleArmory:ShowInFrame(SimpleArmory:GetAllMounts())
            elseif commandArg1 == "my" then
                SimpleArmory:ShowInFrame(SimpleArmory:GetAllMyMounts(commandArg2))
            elseif commandArg1 == "myj" then
                SimpleArmory:ShowInFrame(SimpleArmory:GetAllMyMountsJSON())
            elseif commandArg1 == "pets" then
                SimpleArmory:ShowInFrame(SimpleArmory:GetAllPets())
            elseif commandArg1 == "toys" then
                SimpleArmory:ShowInFrame(SimpleArmory:GetAllToys())
            end
        else
            SimpleArmory:PrintUsage()
        end
    end
end

function SimpleArmory:PrintUsage()
    SimpleArmory:Print("USAGE:")
    SimpleArmory:Print("  /sa toys - exports toys")
end

function SimpleArmory:ShowInFrame(output)
    SACopyFrame:Show()
    SACopyFrameScroll:Show()
    SACopyFrameScrollText:Show()
    SACopyFrameScrollText:SetText(output)
    SACopyFrameScrollText:HighlightText()
    SACopyFrameScrollText:SetScript("OnEscapePressed", function(self)
      SACopyFrame:Hide()
    end)
end

function SimpleArmory:GetAllMounts()
    printToChat("Getting all mounts from game...");

    local mountList = {};
    local mountIDs = C_MountJournal.GetMountIDs();
    for i, id in pairs(mountIDs) do
            local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(id)
            local creatureDisplayID, descriptionText, sourceText, isSelfMount, mountType = C_MountJournal.GetMountInfoExtraByID(id)
            local mountObj = {}

            mountObj["name"] = creatureName;
            mountObj["spellID"] = spellID;
            mountObj["icon"] = icon;
            --mountObj["active"] = active;
            --mountObj["isUsable"] = isUsable;
            --mountObj["sourceType"] = sourceType;
            mountObj["isFactionSpecific"] = isFactionSpecific;
            mountObj["faction"] = faction;
            --mountObj["hideOnChar"] = hideOnChar;
            --mountObj["isCollected"] = isCollected;
            mountObj["mountID"] = mountID;
            --mountObj["creatureDisplayID"] = creatureDisplayID;
            --mountObj["descriptionText"] = descriptionText;
            --mountObj["sourceText"] = sourceText;
            --mountObj["isSelfMount"] = isSelfMount;
            --mountObj["mountType"] = mountType;

            mountList[i] = toJSON(mountObj);
    end --for

    SimpleArmory.MountList = "[" .. table.concat(mountList,",") .. "]";
    return SimpleArmory.MountList
end

-- /sa dev my 1006
function SimpleArmory:GetAllMyMounts(ID)
    printToChat("Getting all my usable mounts...");

    local outStr = ""

    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, 
          isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(ID)
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(ID)


    outStr = outStr .. ID .. ": " .. creatureName .. "\n";
    outStr = outStr .. "   isUsable: " .. tostring(isUsable) .. "\n";
    outStr = outStr .. "   isFactionSpecific: " .. tostring(isFactionSpecific) .. "\n";
    outStr = outStr .. "   faction: " .. tostring(faction) .. "\n";
    outStr = outStr .. "   isCollected: " .. tostring(isCollected) .. "\n";
    outStr = outStr .. "   isSelfMount: " .. tostring(isSelfMount) .. "\n";
    outStr = outStr .. "   hideOnChar: " .. tostring(hideOnChar) .. "\n";
    outStr = outStr .. "   mountType: " .. mountTypeID

    return outStr
end

-- /sa dev myj
function SimpleArmory:GetAllMyMountsJSON()
    printToChat("Getting all my usable mounts to JSON...");

    local mountList = {};
    local mountCount = 0;
    local mountIDs = C_MountJournal.GetMountIDs();
    for i, id in pairs(mountIDs) do
        local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(id)
        local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(id)

        -- Add to the mount list only if its collected and usable
        -- NOTE: dont use isUsable, as that will filter out stuff like water mounts while
        --       you're on land
        if (isCollected and (isFactionSpecific == false or (faction == 1))) then
            local mountObj = {}
            mountObj["id"] = id;
            mountObj["name"] = creatureName;
            mountList[mountCount] = toJSON(mountObj);
            mountCount = mountCount + 1;
        end

        -- if (isCollected and isUsable == false) then
        --     print(id .. ": " .. creatureName .. " faction: " .. tostring(isFactionSpecific))
        -- end

        -- if (isCollected and isUsable == false and isFactionSpecific == false) then
        --     print(id .. ": " .. creatureName .. " faction: " .. tostring(isFactionSpecific) .. " hide: " .. tostring(hideOnChar))
        --     missingCount = missingCount + 1
        -- end
        
    end --for
    
    print("Found " .. mountCount .. " Total Mounts.")

    SimpleArmory.MountList = "[" .. table.concat(mountList,",") .. "]";
    return SimpleArmory.MountList
    -- return("[" .. table.concat(mountList,",") .. "]")
end

function SimpleArmory:GetAllPets()
    printToChat("Getting all pets from game...");

    local petList = {};
    local total, owned = C_PetJournal.GetNumPets();
    for i = 1,total do
        --local petID, speciesID, isOwned, _, _, _, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByIndex(i)
        local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i);

        local petObj = {}
        petObj["speciesID"] = speciesID;
        petObj["speciesName"] = speciesName;
        petObj["companionID"] = companionID;
        petObj["icon"] = icon;
        petObj["isWild"] = isWild;

        petList[i] = toJSON(petObj);
    end
    SimpleArmory.PetList = "[" .. table.concat(petList,",") .. "]";
    return SimpleArmory.PetList
end

function SimpleArmory:GetToyList()
    SimpleArmory:Print("Getting all toys from game...")

    C_ToyBox.SetAllSourceTypeFilters(true);
    C_ToyBox.SetAllExpansionTypeFilters(true);
    C_ToyBox.SetCollectedShown(true);
    C_ToyBox.SetUncollectedShown(true);
    C_ToyBox.SetUnusableShown(true);
    C_ToyBox.SetFilterString("");

    local NumToys = C_ToyBox.GetNumToys();
    local toyList = {};
    for idx = NumToys, 1, -1 do
        local itemId = C_ToyBox.GetToyFromIndex(idx)
        if itemId ~= -1 then
            table.insert(toyList, itemId)
        end
    end
    return toyList
end

function SimpleArmory:GetAllToys()
    return toJSON(SimpleArmory:GetToyList());
end

function SimpleArmory:ExportToys()
    collectedToyList = {}
    for i, id in pairs(SimpleArmory:GetToyList()) do
        if PlayerHasToy(id) then
            table.insert(collectedToyList, id)
        end
    end
    return toJSON(collectedToyList)
end


function printToChat(msg)
  DEFAULT_CHAT_FRAME:AddMessage(GREEN_FONT_COLOR_CODE.."SA: |r"..tostring(msg))
end
