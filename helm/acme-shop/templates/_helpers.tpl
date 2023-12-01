{{/*
Expand the name of the chart.
*/}}
{{- define "acme-shop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "acme-shop.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "acme-shop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acme-shop.labels" -}}
helm.sh/chart: {{ include "acme-shop.chart" . }}
{{ include "acme-shop.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: acme-shop
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acme-shop.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acme-shop.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
TODO(TEAM-INFRA): Refactor these service-specific helpers into a loop
*/}}

{{/*
Gateway labels
*/}}
{{- define "acme-shop.gateway.labels" -}}
{{ include "acme-shop.labels" . }}
app.kubernetes.io/component: gateway
{{- end }}

{{- define "acme-shop.gateway.selectorLabels" -}}
{{ include "acme-shop.selectorLabels" . }}
app.kubernetes.io/component: gateway
{{- end }}

{{/*
Users Service labels
*/}}
{{- define "acme-shop.usersService.labels" -}}
{{ include "acme-shop.labels" . }}
app.kubernetes.io/component: users-service
{{- end }}

{{- define "acme-shop.usersService.selectorLabels" -}}
{{ include "acme-shop.selectorLabels" . }}
app.kubernetes.io/component: users-service
{{- end }}

{{/*
Orders Service labels
*/}}
{{- define "acme-shop.ordersService.labels" -}}
{{ include "acme-shop.labels" . }}
app.kubernetes.io/component: orders-service
{{- end }}

{{- define "acme-shop.ordersService.selectorLabels" -}}
{{ include "acme-shop.selectorLabels" . }}
app.kubernetes.io/component: orders-service
{{- end }}

{{/*
Payments Service labels
*/}}
{{- define "acme-shop.paymentsService.labels" -}}
{{ include "acme-shop.labels" . }}
app.kubernetes.io/component: payments-service
{{- end }}

{{- define "acme-shop.paymentsService.selectorLabels" -}}
{{ include "acme-shop.selectorLabels" . }}
app.kubernetes.io/component: payments-service
{{- end }}

{{/*
Notifications Service labels
*/}}
{{- define "acme-shop.notificationsService.labels" -}}
{{ include "acme-shop.labels" . }}
app.kubernetes.io/component: notifications-service
{{- end }}

{{- define "acme-shop.notificationsService.selectorLabels" -}}
{{ include "acme-shop.selectorLabels" . }}
app.kubernetes.io/component: notifications-service
{{- end }}

{{/*
Frontend Web labels
*/}}
{{- define "acme-shop.frontendWeb.labels" -}}
{{ include "acme-shop.labels" . }}
app.kubernetes.io/component: frontend-web
{{- end }}

{{- define "acme-shop.frontendWeb.selectorLabels" -}}
{{ include "acme-shop.selectorLabels" . }}
app.kubernetes.io/component: frontend-web
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "acme-shop.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acme-shop.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create image pull secret reference
*/}}
{{- define "acme-shop.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create full image path
*/}}
{{- define "acme-shop.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .image.repository -}}
{{- $tag := .image.tag | default "latest" -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end }}
