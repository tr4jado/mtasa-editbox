# Editbox para MTA em Lua

Este é um código de uma classe `Editbox` para Multi Theft Auto (MTA) em Lua. A classe permite criar caixas de texto editáveis com funcionalidades básicas de entrada de texto e seleção.

## Exemplo de Uso

Para criar uma nova instância da `Editbox` e desenhá-la na tela, você pode usar o seguinte código:
```lua
-- Cria uma nova instância de Editbox com uma fonte personalizada
local editbox = Editbox.new({
    font = dxCreateFont("font.ttf", 10) -- Fonte usada para o texto da caixa
})

-- Adiciona um manipulador de eventos para desenhar a caixa de texto na tela
addEventHandler("onClientRender", root, function()
    -- Desenha um retângulo de fundo para a caixa de texto
    dxDrawRectangle(5, 5, 210, 30, tocolor(0, 0, 0, 200))
    -- Desenha a caixa de texto na tela
    editbox:draw("Digite aqui...", 10, 10, 200, 20, tocolor(255, 255, 255))
end)

-- Adiciona um manipulador de eventos para alternar a máscara de texto com a tecla 'k'
bindKey("k", "down", function()
    -- Obtém o estado atual da máscara
    local mask = editbox:getProperties("mask")
    -- Alterna o estado da máscara
    editbox:setProperties("mask", not mask)
end)
```

## Funções Principais

### `Editbox.new(properties)`

Cria uma nova instância de `Editbox` com as propriedades fornecidas.

**Parâmetros:**
- `properties` (tabela): Propriedades da caixa de texto, como `font`, `align`, `mask`, etc.

**Retorno:**
- Instância de `Editbox`

### `Editbox:draw(display, x, y, width, height, color)`

Desenha a caixa de texto na tela.

**Parâmetros:**
- `display` (string): Texto a ser exibido quando a caixa estiver vazia.
- `x` (número): Coordenada X da caixa de texto.
- `y` (número): Coordenada Y da caixa de texto.
- `width` (número): Largura da caixa de texto.
- `height` (número): Altura da caixa de texto.
- `color` (cor): Cor do texto.

### `Editbox:setProperties(property, value)`

Define propriedades para a caixa de texto.

**Parâmetros:**
- `property` (string): Nome da propriedade a ser definida.
- `value` (variante): Valor da propriedade.

### `Editbox:getProperties(property)`

Obtém o valor de uma propriedade da caixa de texto.

**Parâmetros:**
- `property` (string): Nome da propriedade a ser obtida.

**Retorno:**
- Valor da propriedade

### `Editbox:destroy()`

Destrói a instância da caixa de texto e a remove da lista de instâncias.

## Contribuições

Sinta-se à vontade para fazer melhorias ou enviar pull requests. 

## Licença

Este código é fornecido sob a [Licença MIT](LICENSE).
