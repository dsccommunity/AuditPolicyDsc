ConvertFrom-StringData -StringData @'
        disabled                            = disabled
        enabled                             = enabled
        AuditpolNotFound                    = (ERROR) auditpol.exe was not found on the system
        RequiredPrivilegeMissing            = (ERROR) A required privilege is not held by the client
        IncorrectParameter                  = (ERROR) The parameter is incorrect
        UnknownError                        = (ERROR) An unknown error has occured: {0}
        ExecuteAuditpolCommand              = Executing 'auditpol.exe {0}'
        GetAuditpolOptionSucceed            = (GET) '{0}'
        GetAuditpolOptionFailed             = (ERROR) getting '{0}'
        SetAuditpolOptionSucceed            = (SET) '{0}' to '{1}'
        SetAuditpolOptionFailed             = (ERROR) setting '{0}' to value '{1}'
        TestAuditpolOptionCorrect           = '{0}' is '{1}'
        TestAuditpolOptionIncorrect         = '{0}' is NOT '{1}'
        GetAuditpolSubcategorySucceed       = (GET) '{0}':'{1}'
        GetAuditPolSubcategoryFailed        = (ERROR) getting '{0}':'{1}'
        SetAuditpolSubcategorySucceed       = (SET) '{0}' audit '{1}' to '{2}'
        SetAuditpolSubcategoryFailed        = (ERROR) setting '{0}' audit '{1}' to '{2}'
        TestAuditpolSubcategoryCorrect      = '{0}':'{1}' is '{2}'
        TestAuditpolSubcategoryIncorrect    = '{0}':'{1}' is NOT '{2}' 
'@

