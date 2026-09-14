param([string]$Database = 'SportsClubDB', [string]$Server = 'localhost', [int]$Port = 5432)
$ErrorActionPreference = 'Stop'
$previousPassword = $env:PGPASSWORD
$passed = 0
function Check([string]$User, [string]$Sql, [bool]$Allowed) {
    $env:PGPASSWORD = if ($User -eq 'lab1_admin') { 'admin' } else { '123' }
    $result = & psql -X -w -h $Server -p $Port -U $User -d $Database -v ON_ERROR_STOP=1 -v VERBOSITY=verbose -c "BEGIN; SELECT session_user, current_user; $Sql; ROLLBACK;" 2>&1
    $code = $LASTEXITCODE
    $output = $result | Out-String
    if (($Allowed -and $code -ne 0) -or (-not $Allowed -and ($code -eq 0 -or $output -notmatch '42501'))) {
        throw "FAIL $User : $Sql`n$output"
    }
    $script:passed++
    Write-Output "PASS $User allowed=$Allowed : $Sql"
}
try {
    # Native stderr is captured; SQLSTATE 42501 is required for a denied operation.
    $ErrorActionPreference = 'Continue'
    Check 'lab1_admin' 'CREATE TABLE public.lab1_admin_check(id integer); ALTER TABLE public.lab1_admin_check ADD COLUMN note text; DROP TABLE public.lab1_admin_check' $true
    Check 'lab1_admin' 'SELECT * FROM public.owner LIMIT 1' $true
    Check 'lab1_analyst' 'SELECT * FROM public.club LIMIT 1' $true
    Check 'lab1_analyst' 'SELECT * FROM public.employee LIMIT 1' $false
    Check 'lab1_analyst' "INSERT INTO public.club(name,foundation_date) VALUES ('LAB1',CURRENT_DATE)" $false
    Check 'lab1_analyst' 'CREATE TABLE public.lab1_forbidden(id integer)' $false
    Check 'lab1_analyst' 'SET ROLE lab1_admin' $false
    Check 'lab1_hr_user' 'SELECT * FROM public.club LIMIT 1' $true
    Check 'lab1_hr_user' "INSERT INTO public.employee(last_name, first_name, salary) VALUES ('LAB1','Test',100); UPDATE public.employee SET salary=101 WHERE last_name='LAB1'" $true
    Check 'lab1_hr_user' 'DELETE FROM public.employee WHERE false' $false
    Check 'lab1_hr_user' 'SELECT * FROM public.owner LIMIT 1' $false
    Check 'lab1_hr_user' 'UPDATE public.match SET result_1=0 WHERE false' $false
    Check 'lab1_events_user' 'SELECT * FROM public.club LIMIT 1' $true
    Check 'lab1_events_user' "INSERT INTO public.match(match_date,match_time) VALUES (DATE '2026-09-14', TIME '12:00'); UPDATE public.match SET result_1=0 WHERE false" $true
    Check 'lab1_events_user' 'SELECT * FROM public.employee LIMIT 1' $false
    Check 'lab1_events_user' 'DELETE FROM public.match WHERE false' $false
    Check 'lab1_guest' 'SELECT * FROM public.club LIMIT 1' $false
    Check 'lab1_delegate' 'SELECT * FROM public.club LIMIT 1' $false
    Write-Output "All $passed checks passed. Test transactions rolled back (sequence values may advance)."
} finally {
    $env:PGPASSWORD = $previousPassword
}
