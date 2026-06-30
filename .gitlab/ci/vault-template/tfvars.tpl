{{- with secret (printf "secret/data/resource-provisioning/%s/%s/%s-%s-vars" (env "CSP") (env "ACCOUNT_NAME") (env "DEPLOYMENT_NAME") (env "CLUSTER_TYPE")) -}}
{{ .Data.data.file }}
{{- end }}
