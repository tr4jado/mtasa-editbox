local editbox = Editbox.new({
    font = 'arial',
    align = 'center',
    max = 100,
    cursor = true
})

addEventHandler('onClientRender', root, function()
    dxDrawRectangle(256, 313, 277, 60, tocolor(0, 0, 0, 250))
    editbox:setProperties('parent', {256, 313, 277, 60)

    editbox:draw('Clique aqui para digitar', 276, 332, 237, 21, tocolor(255, 255, 255))
end)
