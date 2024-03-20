# Biblioteca Editbox

Editbox é uma biblioteca Lua projetada para fornecer funcionalidades de entrada de texto, permitindo aos usuários inserir e manipular texto em uma interface de usuário. Com o Editbox, você pode integrar facilmente caixas de texto em suas aplicações.

## Recursos

- **Entrada de Texto**: Permite aos usuários inserir e manipular texto em uma interface de usuário.
- **Controle de Caracteres e Teclas**: Manipule caracteres e teclas para inserir texto de forma intuitiva.
- **Máscara de Texto**: Máscara opcional para ocultar caracteres sensíveis, como senhas.
- **Seleção de Texto**: Possibilidade de selecionar todo o texto com uma combinação de teclas.
- **Controle do Cursor**: Exibe um cursor interativo para indicar a posição de inserção de texto.

## Instalação

1. Adicione o arquivo `editbox.lua` ao seu script.
2. No arquivo `meta.xml`, certifique-se de que o método `oop` esteja habilitado no seu ambiente Lua.
   ```xml
   <oop>true</oop>
   ```
3. No arquivo `meta.xml`, adicione o seguinte código para reconhecer a biblioteca:
   ```xml
   <script src='editbox.lua' type='client' cache='false' />
   ```

## Uso

### Criando uma Caixa de Texto

```lua
local properties = {
    font = 'default-bold', -- Fonte do texto
    align = 'left', -- Alinhamento do texto ('left', 'center', 'right')
    max = 50, -- Número máximo de caracteres
    wordbreak = false, -- Quebra de linha (true/false)
    mask = false, -- Mascaramento de texto (true/false)
    maskchar = '*', -- Caractere de máscara (apenas se 'mask' for true)
    isnumber = false, -- Aceitar apenas números (true/false)
    cursor = true -- Exibir cursor (true/false)
    parent = {0, 0, 0, 0} -- Posição do fundo do editbox
}
local editbox = Editbox.new(properties)
```

### Desenhando a Caixa de Texto

```lua
function onRender()
    editbox:draw(textoDeExibição, x, y, largura, altura, cor)
end
```

```lua
editbox:setProperties(propriedade, valor)
```

#### Propriedades:

### Destruindo o ColorPicker

```lua
editbox:destroy()
```

### Eventos

O Editbox captura diversos eventos relacionados à entrada de texto, tais como `onClientCharacter`, `onClientKey`, `onClientPaste`, e `onClientClick`, para oferecer uma experiência de entrada de texto completa e interativa.

## Exemplo

```lua
local editbox = Editbox.new({
    font = 'arial',
    align = 'center',
    max = 20,
    cursor = false
})

addEventHandler('onClientRender', root, function()
    dxDrawRectangle(256, 313, 277, 60, tocolor(0, 0, 0, 250))
    editbox:draw('Clique aqui para digitar', 276, 332, 237, 21, tocolor(255, 255, 255))
end)
```

## Licença

Esta biblioteca é licenciada sob a Licença MIT. Consulte o arquivo [LICENSE](LICENSE) para obter detalhes.

---

Sinta-se à vontade para personalizar e integrar a biblioteca Editbox em seus projetos. Se encontrar problemas ou tiver sugestões para melhorias, não hesite em [reportá-los](https://github.com/yourusername/Editbox/issues).
