# API simulada — Mockoon

O arquivo [Drivr API.json](Drivr%20API.json) é um ambiente exportado do
Mockoon Desktop, chamado `Drivr API`. Ele configura o prefixo de endpoint
vazio, porta `3000` e latência global `0 ms`. A API é local e demonstrativa;
não substitui um backend nem deve receber dados reais.

## Iniciar o ambiente

1. Instale e abra o Mockoon Desktop.
2. Importe o arquivo `Drivr API.json` usando a opção de importar um ambiente
   por arquivo.
3. Selecione o ambiente importado e inicie o servidor. A porta definida no
   export é `3000`.
4. Verifique a resposta, por exemplo:

   ```bash
   curl -i http://localhost:3000/cars
   ```

O Shell usa `API_BASE_URL`. Para o simulador Android, a máquina host costuma
ser acessada por `http://10.0.2.2:3000`; para iOS Simulator, use
`http://localhost:3000`. O README da [Shell App](../../apps/shell_app/README.md)
detalha os comandos de execução e os parâmetros.

## Endpoints configurados

| Método e path | Configuração observada no export |
|---|---|
| `GET /cars` | Rota CRUD ligada ao Data Bucket `cars`; sucesso configurado com 800 ms. Há também uma rota HTTP separada no mesmo método/path com resposta 500. |
| `GET /cars/:id` | A rota CRUD `cars` usa `id` como chave e fornece consulta por item. |
| `POST /bookings/quote` | Resposta templated com 800 ms; lê `carId`, `startDate`, `endDate` e `days`, calcula diária e total a partir do Data Bucket. |
| `POST /auth/login` | Resposta de sucesso com 800 ms e token/usuário fictícios; possui uma resposta 401 alternativa. |
| `POST /auth/register` | Resposta 201 com 800 ms e status `simulated`; não cria uma conta persistida. |
| `GET /users/me` | Resposta de perfil 200 com 800 ms e uma resposta 401 alternativa. |
| `POST /bookings` | Resposta 201 `confirmed`, com id gerado e campos interpolados da requisição; também declara resposta 401 alternativa. |
| `GET /catalog/home-layout` | Documento SDUI v2 de Catalog, com latência configurada em 1200 ms. |
| `GET /account/profile-layout` | Documento SDUI v2 de Account e resposta 500 alternativa; latência de 0 ms. |

O Data Bucket `cars` contém os IDs `car-001` a `car-004`, correspondentes a
Audi RS 5, Porsche Panamera, Chevrolet Corvette Z06 e Lamborghini Huracán.
`POST /bookings/quote` retorna 400 quando `days` não é maior que zero e 404
quando não encontra o carro no bucket.

## Credenciais de demonstração

O response de sucesso de login no JSON contém as seguintes credenciais:

```text
E-mail: demo@drivr.local
Senha: 123456
Token: drivr-demo-token
```

Use-as somente para desenvolvimento local. O login retorna o token como
`accessToken`; o Shell o mantém em memória e o Core o envia em requests não
relacionados a `/auth/` quando há sessão.

## Latência e respostas de falha

As latências são definidas por resposta no arquivo exportado, não por um
script do repositório. Há respostas com 800 ms e 1200 ms, enquanto a latência
global é zero. Para experimentar outros tempos, ajuste o campo de latência da
resposta no ambiente Mockoon.

O export contém respostas alternativas 401 e 500. Há, porém, detalhes que
afetam a seleção e devem ser conferidos antes de usar esses casos como teste
determinístico:

- O `GET /cars` de erro é uma rota HTTP duplicada do `GET /cars` CRUD. Ambas
  têm respostas padrão no export. Ao testar 500, evite manter as duas rotas
  concorrendo pelo mesmo método e path; confirme o status observado com
  `curl`.
- As respostas 401 de login, perfil e reserva estão declaradas como não
  padrão e sem regras próprias; os responses de sucesso estão marcados como
  padrão. A configuração, portanto, não documenta de forma inequívoca que
  credenciais inválidas ou requests sem token selecionem as respostas 401.
- A rota `POST /bookings` não possui regra de request que valide o header
  `Authorization` para o response de sucesso. Existe uma resposta 401
  alternativa, mas o export não declara a condição que a seleciona.
- O response 200 de `GET /users/me` tem regra de igualdade para
  `Authorization: Bearer drivr-demo-token`; confirme no Mockoon como o
  response alternativo 401 é selecionado para requests sem correspondência.
- A rota de `GET /account/profile-layout` declara 500 alternativo sem regra;
  confira a seleção do response antes de usá-lo para reproduzir falha.

O ambiente também contém um response de login bem-sucedido cujas regras
exigem simultaneamente o e-mail e a senha fictícios. Como o response de
sucesso está marcado como padrão, teste a resposta de credenciais inválidas
no Mockoon em vez de presumir que a variante 401 será selecionada. Se
precisar reproduzir falhas de forma determinística, ajuste as regras/responses
na cópia local do ambiente e valide cada cenário por HTTP.

## Persistência e divergências conhecidas

Cadastro e reserva são respostas simuladas: o ambiente não configura um banco
de usuários nem uma operação de negócio persistente para esses endpoints. O
Data Bucket de carros é conteúdo de mockoon; o app não deve tratá-lo como uma
fonte de dados de produção.

O README raiz lista `/bookings` e `/users/me` como endpoints que requerem
Bearer token. O export tem uma regra de header no sucesso de `/users/me`, mas
não tem regra equivalente no sucesso de `/bookings`; as alternativas 401
também não têm condições explícitas no JSON. O código do app envia token
quando autenticado, mas isso não significa que o Mockoon esteja validando
autorização em todos esses endpoints.

Não há script de inicialização, configuração de Mockoon CLI ou testes
automatizados do ambiente neste diretório; a execução descrita aqui é pelo
Mockoon Desktop e pelo arquivo exportado.
