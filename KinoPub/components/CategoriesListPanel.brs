sub init()
    print "CategoriesListPanel:init()"
    m.top.panelSize = "medium"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = true

    m.top.optionsAvailable = false
    m.top.overhangTitle = "Kino.Pub"
    m.top.list = m.top.findNode("categoriesLabelList")
    
    m.currentCategory = ""
    m.top.observeField("start","start")
end sub

sub start()
    print "CategoriesListPanel:start()"
    m.readContentTask = createObject("roSGNode", "ContentReader")
    m.readContentTask.observeField("content", "setcategories")
    
    if m.top.pType <> "bookmarks"
        m.readContentTask.baseUrl = "https://api.service-kp.com/v1/types"
    else
        m.readContentTask.baseUrl = "https://api.service-kp.com/v1/bookmarks"
    end if
    
    m.readContentTask.parameters = ["access_token", m.global.accessToken]
    m.readContentTask.control = "RUN"
    
end sub

sub setCategories()
    print "CategoriesListPanel:setCategories()"
    
    content = createObject("roSGNode", "ContentNode")
    if(m.top.pType <> "bookmarks")
        itemcontent = content.createChild("ContentNode")
        itemcontent.setField("id", "bookmarks")
        itemContent.addFields({ kinoPubId: "bookmarks"})
        itemcontent.setField("title", recode("Закладки"))
        
        itemId = 0
        for each item in m.readContentTask.content.items
            itemcontent = content.createChild("ContentNode")
            itemcontent.setField("id", itemId.ToStr())
            itemcontent.addFields({ kinoPubId: item.id})
            itemcontent.setField("title", recode(item.title))
            itemId = itemId+1
        end for
        
    else
        itemId = 0
        for each item in m.readContentTask.content.items
            itemcontent = content.createChild("ContentNode")
            itemcontent.setField("id", itemId.ToStr())
            itemcontent.addFields({kinoPubId: item.id.ToStr()})
            itemcontent.setField("title", recode(item.title))
            itemId = itemId+1
        end for
    end if
    
    m.top.list.content = content
    m.top.list.observeField("itemFocused", "itemFocused")
    
    m.emptyPanel = createObject("roSGNode", "EmptyPanel")
    m.emptyPanel.panelSet = m.top.panelSet
    m.emptyPanel.pType = m.top.pType
    m.emptyPanel.observeField("focusedChild", "categorySelected")
    
    m.top.panelSet.appendChild(m.emptyPanel)
    
    m.top.setFocus(true)
end sub

sub itemFocused()
    print "CategoriesListPanel:itemFocused()"
    categorycontent = m.top.list.content.getChild(m.top.list.itemFocused)
    selectedCategory = categorycontent.kinoPubId.ToStr()
    if selectedCategory = "bookmarks"
        m.preparedPanel = createObject("roSGNode", "CategoriesListPanel")
        m.preparedPanel.previousPanel = m.top
        m.preparedPanel.panelSet = m.top.panelSet
        m.preparedPanel.pType = "bookmarks"
        m.currentCategory = "bookmarks"
    else 
        m.preparedPanel = createObject("roSGNode", "PosterGridPanel")
        m.preparedPanel.previousPanel = m.top
        m.currentCategory = selectedCategory
    end if
end sub

sub categorySelected()
    print "CategoriesListPanel:categorySelected()"
    print m.emptyPanel.isInFocusChain()
    print m.emptyPanel.hasFocus()
    print m.top.panelSet.isGoingBack
    if m.emptyPanel.isInFocusChain()
        if not m.top.panelSet.isGoingBack
            if m.currentCategory <> "bookmarks"
                if m.top.pType <> "bookmarks"
                    m.preparedPanel.gridContentBaseUri = "https://api.service-kp.com/v1/items"
                    m.preparedPanel.gridContentUriParameters = ["access_token", m.global.accessToken, "type", m.currentCategory]
                else
                    m.preparedPanel.gridContentBaseUri = "https://api.service-kp.com/v1/bookmarks/" + m.currentCategory
                    m.preparedPanel.gridContentUriParameters = ["access_token", m.global.accessToken]
                end if
            end if
            
            m.top.nextPanel = m.preparedPanel
        else
            m.emptyPanel.setFocus(false)
            m.top.list.setFocus(true)
        end if
    end if
end sub

sub recode(str as string) as string
    return m.global.utilities.callFunc("Encode", {str: str})
end sub