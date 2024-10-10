# Editbox para MTA:SA

Esta utilidade fornece um componente editbox personalizável para **Multi Theft Auto: San Andreas (MTA:SA)**, permitindo a fácil integração de campos de entrada de texto com recursos como controle de cursor, máscara de caracteres e interação com a área de transferência.

## Funcionalidades

- **Entrada de Texto Personalizável**: Defina propriedades como fonte, texto e tamanho.
- **Controle de Cursor**: Suporta navegação do cursor com as teclas de seta.
- **Entrada Mascarada**: Opção para mascarar a entrada (por exemplo, para campos de senha).
- **Interação com Área de Transferência**: Suporte para copiar e colar via área de transferência.
- **Manipulação de Eventos**: Lida com entradas de teclas, cliques e entrada de texto.
- **Seleção de Texto**: Permite seleção de texto e operações rápidas (recortar, copiar, colar).
- **Suporte a Placeholder**: Desenha um placeholder quando o campo de texto está vazio e sem foco.
- **Opção para Entrada Numérica**: Limita a entrada apenas a números.

## Uso

### 1. Criando um Editbox
Você pode criar uma nova instância de um editbox usando o método `Editbox.new(properties)`. Você pode personalizá-lo passando as seguintes propriedades opcionais:

```lua
local editbox = Editbox.new({
    text = "Olá",
    font = "default-bold",
    masked = false,  -- Defina como uma string para ativar a máscara (ex: "*")
    is_number = true, -- Defina como true para permitir apenas entrada numérica
    max_length = 12,  -- Limite o texto a 12 caracteres
    parent = {x, y, largura, altura} -- Posição ao clicar, a editbox ficar em foco
})
```

### 2. Desenhando o Editbox
Para renderizar o editbox na tela, use o método `draw()`. Este método suporta parâmetros como texto placeholder, posição, tamanho e cor.

```lua
editbox:draw("Digite o texto...", x, y, largura, altura, tocolor(255, 255, 255))
```

### 3. Manipulação de Eventos
A utilidade lida automaticamente com vários eventos do cliente, como pressionamento de teclas, entrada de texto e cliques. Não é necessário adicionar manualmente listeners de eventos:

- **onClientClick**: Lida com cliques para focar ou interagir com o editbox.
- **onClientCharacter**: Adiciona caracteres ao editbox ao digitar.
- **onClientKey**: Lida com ações de teclas como setas para mover o cursor, backspace e delete.
- **onClientPaste**: Suporta colar texto da área de transferência.

### 4. Operações de Teclas
Aqui estão algumas operações de teclas suportadas pelo editbox:

- **Seta Esquerda** (`arrow_l`): Move o cursor para a esquerda.
- **Seta Direita** (`arrow_r`): Move o cursor para a direita.
- **Backspace**: Apaga o caractere antes do cursor.
- **Delete**: Apaga o caractere após o cursor.
- **Ctrl + A**: Seleciona todo o texto.
- **Ctrl + C**: Copia o texto selecionado.
- **Ctrl + X**: Recorta o texto selecionado.

### 5. Gerenciamento de Cursor e Deslocamento
O editbox gerencia a posição do cursor e o deslocamento do texto para lidar com rolagem quando a entrada excede a largura disponível. Isso garante uma experiência de usuário suave.

## Exemplo

```lua
local meuEditbox = Editbox.new({
    text = "",
    font = "default",
    masked = false,
    is_number = false,
    max_length = 20
})

addEventHandler("onClientRender", root, function()
    meuEditbox:draw("Digite seu nome...", 500, 300, 200, 30, tocolor(255, 255, 255))
end)
```

## Licença

Este software é de uso livre, permitido modificar e distribuir, desde que sejam dados os devidos créditos ao autor original. Ao utilizar este software ou qualquer modificação dele, você concorda em manter uma referência ao autor original em seus projetos ou distribuições. 

---

Com esta utilidade, você pode criar facilmente campos de entrada de texto com funcionalidade aprimorada, adaptada ao seu servidor MTA:SA. Aproveite a flexibilidade e a facilidade de personalização!
