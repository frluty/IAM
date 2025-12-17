flowchart TD
 subgraph subGraph0["Edge & ZTNA"]
        W["Azure AD Conditional Access"]
        Z["Azure Front Door + ZTNA"]
  end
 subgraph subGraph1["IGA Core - MidPoint Cluster"]
        P[("PostgreSQL Hyperscale")]
        M1["MidPoint Pod 1"]
        M2["MidPoint Pod 2"]
        M3["MidPoint Pod 3"]
        R["Redis Enterprise"]
        N["Neo4j Graph DB<br>Relations IAM"]
  end
 subgraph subGraph2["AM/PAM - Azure Native"]
        PI["PIM JIT + MFA"]
        E["Entra ID P2"]
        KV["Key Vault HSM"]
        F["Azure Functions<br>Rotation Auto"]
  end
 subgraph subGraph3["AI Brain - Serverless"]
        UE["Sentinel UEBA"]
        ML["Azure ML Workspace<br>AutoML + MLOps"]
        LA["Logic Apps SOAR"]
        BOT["Azure AI Bot<br>Copilot IAM"]
  end
 subgraph subGraph4["Observability & GitOps"]
        AI["App Insights"]
        OT["OpenTelemetry"]
        G["Grafana Cloud"]
        GH["GitHub Actions"]
        TF["Terraform Cloud"]
        AKS["AKS Cluster"]
  end
 subgraph subGraph5["Data Protection"]
        PU["Azure Purview"]
        V["Varonis"]
        DLP["Defender for Cloud Apps"]
  end
    Z --> W & M1 & E & ML
    M1 --> P & R & N & E
    M2 --> P
    M3 --> P
    E --> PI & KV
    KV --> F
    ML --> UE & M1 & PI & LA
    UE --> LA
    LA --> BOT & M1 & E & KV
    OT --> AI
    AI --> G
    TF --> GH
    GH --> AKS
    V --> PU
    PU --> DLP
    OT -.-> M1 & E & ML & LA

    style W fill:#0078D4,stroke:#003087,color:#fff
    style Z fill:#0078D4,stroke:#003087,color:#fff
    style P fill:#107C10,stroke:#006400,color:#fff
    style M1 fill:#107C10,stroke:#006400,color:#fff
    style M2 fill:#107C10,stroke:#006400,color:#fff
    style M3 fill:#107C10,stroke:#006400,color:#fff
    style R fill:#107C10,stroke:#006400,color:#fff
    style N fill:#107C10,stroke:#006400,color:#fff
    style PI fill:#F25022,stroke:#B33C00,color:#fff
    style E fill:#F25022,stroke:#B33C00,color:#fff
    style KV fill:#F25022,stroke:#B33C00,color:#fff
    style F fill:#F25022,stroke:#B33C00,color:#fff
    style UE fill:#68217A,stroke:#3D0066,color:#fff
    style ML fill:#68217A,stroke:#3D0066,color:#fff
    style LA fill:#68217A,stroke:#3D0066,color:#fff
    style BOT fill:#68217A,stroke:#3D0066,color:#fff
    style AI fill:#FFD600,stroke:#B39700,color:#000
    style OT fill:#FFD600,stroke:#B39700,color:#000
    style G fill:#FFD600,stroke:#B39700,color:#000
    style GH fill:#FFD600,stroke:#B39700,color:#000
    style TF fill:#FFD600,stroke:#B39700,color:#000
    style AKS fill:#FFD600,stroke:#B39700,color:#000
    style PU fill:#605E5C,stroke:#3C3C3C,color:#fff
    style V fill:#605E5C,stroke:#3C3C3C,color:#fff
    style DLP fill:#605E5C,stroke:#3C3C3C,color:#fff
    style subGraph0 fill:#BBDEFB
    style subGraph5 fill:#757575
    style subGraph4 fill:#FFF9C4
    style subGraph2 fill:#FFCDD2
    style subGraph1 fill:#C8E6C9
    style subGraph3 fill:#E1BEE7


