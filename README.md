# Projeto autenticação / autorização aws
## Arquitetura implementada

![Texto alternativo da imagem](./assets/arquitetura1.png)

Este projeto implementa uma arquitetura básica de autorização e autenticação aws. Serverless totalmente gerenciada, que pode escalar para milhares de usuários de maneira bem tranquila!

# Como foi organizado o projeto ?


<table style="border: 0" width="100%">
  <tr>
    <td style="border:0; vertical-align: top;" >
      <img src="./assets/folders_estrutura.png" alt="Estrutura de pastas do projeto">
    </td>
    <td style="border:0; vertical-align: top; text-align: left;">
      <strong>assets/:</strong> contêm todas as imagens do projeto.</br></br>
      <strong>main.tf:</strong> gerencia os módulos terraform que ficam na pasta terraform</br></br>
      <strong>Makefile:</strong> automatiza alguns scripts</br></br>
      <strong>output.tf:</strong> recebe todas as saidas dos módulos terraform</br></br>
      <strong>src/:</strong> contêm as funções lambdas e seus pacotes.</br></br>
      <strong>terraform/:</strong> contêm todos os módulos que cria cada recurso
    </td>
  </tr>
</table>

# Configurações necessárias

1 - Certifique-se de ter o AWS CLI instalado, no meu caso utilizei a versão.
    
    aws-cli/2.15.25

2 - A maioria dos comandos do Makefile foi feito para Linux/Ubuntu pois usa rm, zip. Se você não usa WSL ou Linux, terá que rodar alguns comandos na mão para testar a aplicação.

3 - Você precisa ter o terraform instalado! Aqui utilizei ele na versão:

    Terraform v1.7.5

# Como rodar o projeto ?

1 - Depois de clonar o projeto e configurar o aws cli para sua conta da aws, você pode visualizar o que será feito através do comando:

    terraform plan
