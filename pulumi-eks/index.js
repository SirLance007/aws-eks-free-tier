"use strict";
const pulumi = require("@pulumi/pulumi");
const awsx = require("@pulumi/awsx");
const eks = require("@pulumi/eks");
const k8s = require("@pulumi/kubernetes");

// Load configuration
const config = new pulumi.Config();
const enableTeleport = config.getBoolean("enableTeleport") || false;
const teleportProxyAddr = config.get("teleportProxyAddr");
const teleportJoinToken = config.getSecret("teleportJoinToken");
const teleportNamespaceName = config.get("teleportNamespace") || "teleport";

// 1. Create a VPC for the EKS Cluster
const vpc = new awsx.ec2.Vpc("eks-vpc", {
    numberOfAvailabilityZones: 2,
    tags: {
        Name: "pulumi-eks-vpc",
        Project: "Pulumi-EKS-Practice",
    }
});

// 2. Create the EKS Cluster
const cluster = new eks.Cluster("eks-cluster", {
    vpcId: vpc.vpcId,
    subnetIds: vpc.publicSubnetIds,
    instanceType: "t3.micro",
    desiredCapacity: 1,
    minSize: 1,
    maxSize: 2,
    createOidcProvider: true, // Enables IAM Roles for Kubernetes Service Accounts (IRSA)
});

// 3. Create a Kubernetes Provider linked to our new EKS cluster
const k8sProvider = new k8s.Provider("k8s-provider", {
    kubeconfig: cluster.kubeconfig,
});

// 4. Optionally deploy Teleport agent Helm Chart
if (enableTeleport) {
    if (!teleportProxyAddr || !teleportJoinToken) {
        throw new Error("Missing required configuration for Teleport: teleportProxyAddr and teleportJoinToken must be set when enableTeleport is true.");
    }

    const ns = new k8s.core.v1.Namespace("teleport-ns", {
        metadata: { name: teleportNamespaceName }
    }, { provider: k8sProvider });

    const teleportAgent = new k8s.helm.v3.Release("teleport-agent", {
        chart: "teleport-kube-agent",
        version: "18.9.1", // Matching the version from the generated command
        repositoryOpts: {
            repo: "https://charts.releases.teleport.dev",
        },
        namespace: ns.metadata.name,
        values: {
            roles: "kube,app,discovery",
            authToken: teleportJoinToken,
            proxyAddr: teleportProxyAddr,
            kubeClusterName: cluster.eksCluster.name,
            enterprise: true,
            updater: {
                enabled: true,
                releaseChannel: "stable/cloud",
            },
            highAvailability: {
                replicaCount: 2,
                podDisruptionBudget: {
                    enabled: true,
                    minAvailable: 1,
                },
            },
        },
    }, { provider: k8sProvider, dependsOn: [ns] });
}

exports.vpcId = vpc.vpcId;
exports.clusterName = cluster.eksCluster.name;
exports.kubeconfig = cluster.kubeconfig;