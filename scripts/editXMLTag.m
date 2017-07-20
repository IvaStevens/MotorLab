function editXMLTag(tag, newInfo, xDoc)
    allListItems = xDoc.getElementsByTagName(tag);
    N = allListItems.getLength;
    
    if isnumeric(newInfo)
        newInfo = sprintf(' %0.2f %0.2f', newInfo);
    end
    
    for n = 0:N-1
        thisListItem = allListItems.item(n);
        if strcmp(tag, 'ScaleTool')
            thisListItem.setAttribute('name', newInfo)
        end
        thisListItem.getFirstChild.setData(newInfo);
    end
