-- Créer une table pour stocker les données CSV
local csvData = {}



-- Fonction pour analyser le texte CSV et le charger dans la table
local function ParseCSV(csvText)
    -- Diviser le texte CSV en lignes
    local lines = { strsplit("\n", csvText) }

    -- Vérifier si la première ligne est l'en-tête et l'ignorer
    if lines[1] == "Item,ItemID,Name,Plus" then
        table.remove(lines, 1)
    end

    -- Parcourir chaque ligne
    for _, line in ipairs(lines) do
        -- Diviser la ligne en valeurs
        local values = { strsplit(",", line) }

        -- Vérifier que la ligne contient les colonnes attendues
        if #values == 4 then
            local item = values[1]
            local itemId = tonumber(values[2])
            local name = values[3]
            local plus = values[4]

            -- Ajouter les valeurs à la table csvData
            table.insert(csvData, {
                Item = item,
                ItemId = itemId,
                Name = name,
                Plus = plus
            })
        end
    end

    -- Afficher les données chargées dans la console (pour vérification)
    for i, data in ipairs(csvData) do
        print(string.format("Item: %s, ItemId: %d, Name: %s, Plus: %s", data.Item, data.ItemId, data.Name, data.Plus))
    end

    -- Format SRData
    SRData = {} -- let's erase the older data
    for i, data in ipairs(csvData) do
        SRData[data.Name] = SRData[data.Name] or {}
        SRData[data.Name][1]=data.Plus
        SRData[data.Name][2] = SRData[data.Name][2] or {}
        table.insert(SRData[data.Name][2], {data.ItemId, data.Item})
    end
end

-- Fonction pour ouvrir une fenêtre de dialogue et récupérer le texte CSV
function BubbleLoot_G.csv.OpenCSVDialog()


-- MAIN_FRAME
    ---@class Frame : BackdropTemplate https://github.com/Ketho/vscode-wow-api/pull/29
    local dialogFrame = CreateFrame("Frame", "dialogFrame",
        UIParent, BackdropTemplateMixin and "BackdropTemplate")
    -- Mouse
    dialogFrame:SetMovable(true)
    dialogFrame:EnableMouse(true)
    dialogFrame:SetScript("OnMouseUp", function(self_dialogFrame)
                self_dialogFrame:StopMovingOrSizing()
                end)
    


 dialogFrame:SetSize(600, 400)
 dialogFrame:SetPoint("CENTER", UIParent, "CENTER")
 dialogFrame:SetBackdrop({
     bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
     edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
     tile = true,
     tileSize = 32,
     edgeSize = 32,
     insets = { left = 11, right = 12, top = 12, bottom = 11 }
 })
 dialogFrame:EnableMouse(true)
    dialogFrame:SetMovable(true)
    dialogFrame:RegisterForDrag("LeftButton")
    dialogFrame:SetScript("OnDragStart", dialogFrame.StartMoving)
    dialogFrame:SetScript("OnDragStop", dialogFrame.StopMovingOrSizing)

    -- Créer un FontString pour le titre
    local titleFontString = dialogFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleFontString:SetPoint("TOP", dialogFrame, "TOP", 0, -10)
    titleFontString:SetText("Fichier CSV pour la SR au format Item, ItemID, Name, Plus")


    -- Créer un ScrollFrame pour contenir l'EditBox
    local scrollFrame = CreateFrame("ScrollFrame", "CSVImportScrollFrame", dialogFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(560, 300)
    scrollFrame:SetPoint("TOPLEFT", dialogFrame, "TOPLEFT", 20, -30)

    -- Créer une EditBox multiligne pour entrer le texte CSV
    local editBox = CreateFrame("EditBox", "CSVImportEditBox", scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(true)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetSize(540, 300)
    editBox:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    editBox:SetTextInsets(10, 10, 5, 5)
    editBox:SetScript("OnEscapePressed", function() dialogFrame:Hide() end)

    -- Configurer le ScrollFrame pour faire défiler l'EditBox
    scrollFrame:SetScrollChild(editBox)

    -- Créer un bouton OK
    local okButton = CreateFrame("Button", "CSVImportOkButton", dialogFrame, "UIPanelButtonTemplate")
    okButton:SetSize(80, 25)
    okButton:SetPoint("BOTTOMRIGHT", dialogFrame, "BOTTOMRIGHT", -20, 20)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function()
        local csvText = editBox:GetText()
        ParseCSV(csvText)
        dialogFrame:Hide()
    end)

    -- Créer un bouton Annuler
    local cancelButton = CreateFrame("Button", "CSVImportCancelButton", dialogFrame, "UIPanelButtonTemplate")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOMLEFT", dialogFrame, "BOTTOMLEFT", 20, 20)
    cancelButton:SetText("Annuler")
    cancelButton:SetScript("OnClick", function()
        dialogFrame:Hide()
    end)

    -- Afficher la fenêtre de dialogue
    dialogFrame:Show()
end


