# ------------------------------------------------------
# Custom Metric - Logon Mode
#
# Thomas Krampe - t.krampe@loginconsultants.com
# (c) 2015 Login Consultants Germany GmbH
# ------------------------------------------------------

$LogonStatus = Get-AMLogonMode
New-AMMetricFile -Name "Logon Status" -Value $LogonStatus