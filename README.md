
# Classe Editbox - Lua

## Visão Geral

A classe `Editbox` oferece uma caixa de texto personalizável que permite interação do usuário, incluindo digitação, navegação com o cursor, seleção de texto e suporte para área de transferência. A classe foi projetada para ser usada com o jogo MTA:SA, utilizando os métodos de desenho DirectX para renderizar a caixa de entrada.

### Recursos
- Entrada de texto e máscara de caracteres (para campos de senha).
- Movimento do cursor com as teclas de seta do teclado.
- Suporta copiar, colar e selecionar tudo (Ctrl + C, Ctrl + V, Ctrl + A).
- Suporta backspace e delete para manipulação de texto.
- Suporte para fonte personalizada e comprimento máximo do texto.
- Atualiza dinamicamente a renderização do texto e a posição do cursor.
- Renderização baseada em RenderTarget para otimização de desempenho.

## Propriedades

O bloco de propriedades descreve todas as propriedades que podem ser definidas ao criar uma nova instância de `Editbox`:

```lua
Editbox.new({
    font = "default", -- Fonte utilizada para o texto.
    mask = false,     -- Caractere utilizado para mascarar o texto (útil para senhas).
    isNumber = false, -- Define se a entrada deve aceitar apenas números.
    maxLength = 0,    -- Comprimento máximo do texto (0 = ilimitado).
    parent = {-1, -1, 0, 0} -- Definição da área para o clique (x, y, largura, altura).
})
```

## Métodos

### `Editbox.new(properties)`
Cria uma nova instância da classe Editbox. Você pode personalizar várias propriedades, como fonte, texto, comprimento máximo, etc., passando uma tabela `properties`.

### `Editbox:draw(placeholder, x, y, width, height, color)`
Desenha a caixa de texto na tela com a posição, dimensões e cor especificadas. Ele lida com a renderização do texto, exibição de espaço reservado e do cursor.

### `Editbox:setText(text)`
Atualiza o texto na caixa de texto e ajusta a posição do cursor.

### `Editbox:destroy()`
Destrói a instância da caixa de texto, liberando todos os recursos associados e removendo quaisquer manipuladores de eventos ativos.

## Exemplo de Uso

```lua
local editbox = Editbox.new({
    font = "default",
    maxLength = 50,
    mask = "*"
})

function onRender()
    editbox:draw("Digite aqui...", 100, 100, 300, 40, tocolor(255, 255, 255))
    editbox.parent = {100, 100, 300, 40}
end
addEventHandler("onClientRender", root, onRender)
```

Neste exemplo, uma nova `Editbox` é criada com um comprimento máximo de 50 caracteres e entrada mascarada (por exemplo, para campos de senha). O método `draw` é chamado a cada frame para exibir a caixa de texto nas coordenadas especificadas.

## Licença

Este projeto é de uso livre, permitido modificar e distribuir, desde que sejam dados os devidos créditos ao autor original. Ao utilizar este software ou qualquer modificação dele, você concorda em manter uma referência ao autor original em seus projetos ou distribuições.
