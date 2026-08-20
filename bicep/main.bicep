// =============================================
// Azure Ops Platform - Main Bicep Template
// Author: Donatus Emeka Anyalebechi
// Description: Core networking infrastructure
// =============================================

// Parameters - values you can change at deploy time
param location string = 'eastus'
param projectName string = 'azureops'
param environment string = 'Dev'

// Variables - computed values used inside the template
var vnetName = 'vnet-${projectName}'
var subnetName = 'snet-app'
var nsgName = 'nsg-${projectName}'

// =============================================
// RESOURCE 1 - Network Security Group
// Created first because the subnet needs it
// =============================================
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: {
    Project: projectName
    Environment: environment
    Owner: 'Donatus'
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// =============================================
// RESOURCE 2 - Virtual Network with Subnet
// =============================================
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: {
    Project: projectName
    Environment: environment
    Owner: 'Donatus'
  }
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// =============================================
// OUTPUTS - values shown after deployment
// =============================================
output vnetId string = vnet.id
output vnetName string = vnet.name
output subnetId string = vnet.properties.subnets[0].id
output nsgId string = nsg.id
