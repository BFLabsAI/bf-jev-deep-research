#Requires -Version 5.1
<#
Instalador do pacote bf-jev-deep-research (Windows nativo, PowerShell).

Uso (a partir da pasta do projeto onde voce quer instalar):
    iwr -useb https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.ps1 | iex

Ou baixando primeiro e rodando localmente:
    .\setup-bf-jev-deep-research.ps1 -TargetDir "C:\caminho\do\projeto"

O que este script faz, na mesma ordem que a versao bash (setup-bf-jev-deep-research.sh):
  1. Clona o pacote (raso) para uma pasta temporaria.
  2. Copia o pacote inteiro (skill + estudo bruto) para <projeto>\bf-jev-deep-research\
     -- a "biblioteca de referencia" navegavel dentro do projeto.
  3. Instala a SKILL de fato onde o agente vai encontra-la:
       - se <projeto>\agents\skills\ ja existir, instala ali e cria uma JUNCTION
         (nao symlink) em <projeto>\.claude\skills\<nome> apontando para la.
         Junction e usada de proposito: ao contrario de symlink de diretorio,
         nao exige privilegio de administrador nem "Modo de desenvolvedor" ativado.
       - senao, instala direto em <projeto>\.claude\skills\<nome>.
  4. Reescreve os links relativos da copia instalada da skill para a nova
     profundidade (mesma logica da versao bash -- ver comentario la).
#>

param(
    [string]$TargetDir = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$RepoUrl   = "https://github.com/BFLabsAI/bf-jev-deep-research.git"
$PkgName   = "bf-jev-deep-research"
$SkillName = "jev-typesafe-expert"

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "OK  $msg" -ForegroundColor Green }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Este instalador precisa do git no PATH. Instale o Git for Windows e rode de novo."
    exit 1
}

$TmpDir = Join-Path $env:TEMP ("bf-jev-deep-research-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    Info "Baixando $PkgName..."
    git clone --depth=1 --quiet $RepoUrl $TmpDir

    $PkgDest = Join-Path $TargetDir $PkgName
    Info "Instalando a biblioteca de referencia em: $PkgDest"
    if (Test-Path $PkgDest) { Remove-Item $PkgDest -Recurse -Force }
    New-Item -ItemType Directory -Path $PkgDest | Out-Null
    Copy-Item -Path (Join-Path $TmpDir '*') -Destination $PkgDest -Recurse -Force -Exclude ".git"
    Ok "$PkgName\ instalado (skill + estudo bruto navegavel)."

    # --- Decide onde a skill "viva" vai morar ---
    $AgentsSkills = Join-Path $TargetDir "agents\skills"
    $ClaudeSkills = Join-Path $TargetDir ".claude\skills"

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
    Ok "Instalacao concluida."
    Write-Host "  Biblioteca completa (skill + estudo bruto): $PkgDest"
    Write-Host "  Skill ativa para o agente:                  $CanonicalDir"
    Write-Host ""
    Write-Host "Para reinstalar/atualizar, rode este mesmo comando de novo."
}
finally {
    Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
