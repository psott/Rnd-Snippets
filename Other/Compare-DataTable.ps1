#https://gist.github.com/gravejester/40dfc770ba7591e66b16#file-compare-datatable-ps1

function Compare-DataTable {
    <#
        .SYNOPSIS
            Compare two DataTables.
        .DESCRIPTION
            Compare two DataTables.
        .EXAMPLE
            Compare-DataTable -ReferenceTabel $table1 -DifferenceTable $table2 -CompareMode 'Full'
            Performes a full compare of $table1 and $table2
        .NOTES
            Author: Øyvind Kallstad
            Date: 20.10.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter()]
        [System.Data.DataTable] $ReferenceTable,

        [Parameter()]
        [System.Data.DataTable] $DifferenceTable,

        # Schema only compares the table structure while Full compares the data as well.
        [Parameter()]
        [ValidateSet('Full','Schema')]
        [string] $CompareMode = 'Schema'
    )

    if (-not (Compare-DataTableSchema -ReferenceTable $ReferenceTable -DifferenceTable $DifferenceTable)) {
        return $false
    }
    
    if($CompareMode -eq 'Full') {
        foreach ($row in $ReferenceTable.Rows) {
            if (-not(Compare-DataRow -ReferenceRow $row -DifferenceRow ($DifferenceTable.Rows | Where-Object {$_.Name -eq $row.Name}))) {
                return $false
            }
        }
    }

    return $true
}

# Helper function for Compare-DataTable
function Compare-DataColumn {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [System.Data.DataColumn] $ReferenceColumn,
        [System.Data.DataColumn] $DifferenceColumn
    )

    if ($ReferenceColumn.ColumnName -ne $DifferenceColumn.ColumnName) {
        return $false
    }
    if ($ReferenceColumn.DataType -ne $DifferenceColumn.DataType) {
        return $false
    }
    return $true
}

# Helper function for Compare-DataTable
function Compare-DataTableSchema {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [System.Data.DataTable] $ReferenceTable,
        [System.Data.DataTable] $DifferenceTable
    )

    if ($ReferenceTable.Columns.Count -ne $DifferenceTable.Columns.Count) {
        return $false
    }

    else {
        $referenceTableColumns = $ReferenceTable.Columns
        $differenceTableColumns = $DifferenceTable.Columns
        foreach ($column in $referenceTableColumns) {
            if (-not (Compare-DataColumn -ReferenceColumn $column -DifferenceColumn ($differenceTableColumns | Where-Object {$_.Ordinal -eq $column.Ordinal}))) {
                return $false
            }
        }
    }
    return $true
}

# Helper function for Compare-DataTable
function Compare-DataRow {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [System.Data.DataRow] $ReferenceRow,
        [System.Data.DataRow] $DifferenceRow
    )

    foreach ($property in ($ReferenceRow | Get-Member -MemberType 'Property')) {
        $propertyName = $property.Name
        if ($ReferenceRow.$propertyName -ne $DifferenceRow.$propertyName) {
            return $false
        }
    }
    return $true
}
