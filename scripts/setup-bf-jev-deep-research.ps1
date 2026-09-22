#Requires -Version 5.1
<#
Instalador do pacote bf-jev-deep-research (Windows nativo, PowerShell).

Uso — por projeto (instala tudo dentro da pasta atual):
    iwr -useb https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.ps1 | iex

Uso — global (uma unica instalacao em $HOME\bf-jev-deep-research, disponivel
pra todos os projetos; skill fica em $HOME\agents\skills ou $HOME\.claude\skills):
    $script = iwr -useb https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.ps1
    Invoke-Expression "& { $($script.Content) } -Global"

Ou baixando primeiro e rodando localmente:
    .\setup-bf-jev-deep-research.ps1 -TargetDir "C:\caminho\do\projeto"
    .\setup-bf-jev-deep-research.ps1 -Global

O que este script faz, na mesma ordem que a versao bash (setup-bf-jev-deep-research.sh):
  1. Decide a "base" da instalacao: $HOME (com -Global) ou a pasta do projeto
     (padrao -- pasta atual, ou -TargetDir).
  2. Clona o pacote (raso) para uma pasta temporaria.
  3. Copia o pacote inteiro (skill + estudo bruto) para <base>\bf-jev-deep-research\
     -- a "biblioteca de referencia" navegavel, seja dentro do projeto ou
     global em $HOME\bf-jev-deep-research.
  4. Instala a SKILL de fato onde o agente vai encontra-la, dentro dessa mesma base:
       - se <base>\agents\skills\ ja existir, instala ali e cria uma JUNCTION
         (nao symlink) em <base>\.claude\skills\<nome> apontando para la.
         Junction e usada de proposito: ao contrario de symlink de diretorio,
         nao exige privilegio de administrador nem "Modo de desenvolvedor" ativado.
       - senao, instala direto em <base>\.claude\skills\<nome>.
  5. Reescreve os links relativos da copia instalada da skill para a nova
     profundidade (mesma logica da versao bash -- ver comentario la). Como a
     skill instalada e o estudo bruto sempre compartilham a mesma base, essa
     conta de profundidade e sempre igual -- o script decide e grava o caminho
     certo na hora da instalacao.
#>

param(
    [string]$TargetDir = (Get-Location).Path,
    [switch]$Global
)

$ErrorActionPreference = "Stop"

$RepoUrl   = "https://github.com/BFLabsAI/bf-jev-deep-research.git"
$PkgName   = "bf-jev-deep-research"
$SkillName = "jev-typesafe-expert"

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "OK  $msg" -ForegroundColor Green }

if ($Global) {
    $BaseDir = $HOME
    Info "Modo global -- instalando em: $BaseDir"
} else {
    $BaseDir = $TargetDir
    Info "Modo por-projeto -- instalando em: $BaseDir"
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Este instalador precisa do git no PATH. Instale o Git for Windows e rode de novo."
    exit 1
}

$TmpDir = Join-Path $env:TEMP ("bf-jev-deep-research-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    Info "Baixando $PkgName..."
    git clone --depth=1 --quiet $RepoUrl $TmpDir

    $PkgDest = Join-Path $BaseDir $PkgName
    Info "Instalando a biblioteca de referencia em: $PkgDest"
    if (Test-Path $PkgDest) { Remove-Item $PkgDest -Recurse -Force }
    New-Item -ItemType Directory -Path $PkgDest | Out-Null
    Copy-Item -Path (Join-Path $TmpDir '*') -Destination $PkgDest -Recurse -Force -Exclude ".git"
    Ok "$PkgName\ instalado (skill + estudo bruto navegavel)."

    # --- Decide onde a skill "viva" vai morar (sempre dentro da mesma $BaseDir
    #     do estudo bruto -- $HOME no modo global, raiz do projeto no padrao) ---
    $AgentsSkills = Join-Path $BaseDir "agents\skills"
    $ClaudeSkills = Join-Path $BaseDir ".claude\skills"

    $UseAgents = Test-Path $AgentsSkills
    if ($UseAgents) {
        $CanonicalDir = Join-Path $AgentsSkills $SkillName
        Info "Pasta agents\skills detectada -- instalando a skill la e criando junction em .claude\skills."
    } else {
        $CanonicalDir = Join-Path $ClaudeSkills $SkillName
        Info "Sem agents\skills -- instalando direto em .claude\skills."
    }

    if (Test-Path $CanonicalDir) { Remove-Item $CanonicalDir -Recurse -Force }
    New-Item -ItemType Directory -Path $CanonicalDir | Out-Null
    Copy-Item -Path (Join-Path $PkgDest "skill\*") -Destination $CanonicalDir -Recurse -Force

    # --- Reescreve os links relativos da skill instalada ---
    # SKILL.md original usa "../study/..."    (1 nivel)  -> "../../../bf-jev-deep-research/study/..." (3 niveis)
    # references\*.md usa   "../../study/..." (2 niveis) -> "../../../../bf-jev-deep-research/study/..." (4 niveis)
    $DepthUp = "../../../"

    $SkillMdPath = Join-Path $CanonicalDir "SKILL.md"
    (Get-Content $SkillMdPath -Raw) -replace '\]\(\.\./study/', "]($DepthUp$PkgName/study/" |
        Set-Content -Path $SkillMdPath -NoNewline

    $RefsDir = Join-Path $CanonicalDir "references"
    if (Test-Path $RefsDir) {
        Get-ChildItem -Path $RefsDir -Filter "*.md" | ForEach-Object {
            (Get-Content $_.FullName -Raw) -replace '\]\(\.\./\.\./study/', "](${DepthUp}../$PkgName/study/" |
                Set-Content -Path $_.FullName -NoNewline
        }
    }
    Ok "Links da skill reescritos para apontar para $PkgName/study/."

    # --- Junction em .claude/skills quando a instalacao canonica foi em agents/skills ---
    # Junction (nao symlink): funciona sem admin/Developer Mode no Windows.
    if ($UseAgents) {
        if (-not (Test-Path $ClaudeSkills)) {
            New-Item -ItemType Directory -Path $ClaudeSkills | Out-Null
        }
        $LinkPath = Join-Path $ClaudeSkills $SkillName
        if (Test-Path $LinkPath) { Remove-Item $LinkPath -Recurse -Force }
        New-Item -ItemType Junction -Path $LinkPath -Target $CanonicalDir | Out-Null
        Ok "Junction criada: .claude\skills\$SkillName -> agents\skills\$SkillName"
    }

    Write-Host ""
    $modeLabel = if ($Global) { "global" } else { "project" }
    Ok "Instalacao concluida (modo: $modeLabel)."
    Write-Host "  Biblioteca completa (skill + estudo bruto): $PkgDest"
    Write-Host "  Skill ativa para o agente:                  $CanonicalDir"
    Write-Host ""
    if ($Global) {
        Write-Host "Essa skill agora esta disponivel em qualquer projeto seu nesta maquina."
    } else {
        Write-Host "Essa skill esta disponivel so neste projeto."
    }
    Write-Host "Para reinstalar/atualizar, rode este mesmo comando de novo (com -Global se foi assim que instalou)."
}
finally {
    Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
