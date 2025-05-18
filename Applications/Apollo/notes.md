## Supergraph
Supergraph is created in terraform/<cloud provider>/create_graph.sh

this will create an api request to create your new graph and try to link the subgraph schema using rover 

### Persisted Queries
it ALSO tries to set up persisted queries, which I'm not 100% sure what these do yet

## Subgraphs
in the actual reference architecture, when the helm chart for the subgraphs are deployed, it also kicks of a Rover task to publish the subgraphs to the apollo enterprise instance
this is also where I found the expected routing for all of the subgraphs. We're actually going to change this (http://graphql.${{ inputs.subgraph_name }}.svc.cluster.local:4001) to use the same apollo namespace for everything. Just to keep things concise. Will be on the lookout for any abnormalities with this. 

I also had to change some of the names and labels of the deployments and services in order to prevent colissions since I changed them to be in the same namespace

### Manual steps to automate
#### deploy with Rover
```bash
rover subgraph publish ${APOLLO_GRAPH_ID}@${VARIANT} \
  --name ${SUBGRAPH_NAME} \
  --routing-url http://${SUBGRAPH_NAME}.apollo.svc.cluster.local:4001/graphql \
  --schema ./subgraphs/${{SUBGRAPH_NAME}}/schema.graphql \
  --variant current \
  --key ${APOLLO_KEY} \
  --debug
```

#### Deploy Client persisted queries manifest
Don't know what this is yet, but it happens on the PR merge (subgraph build) as well as subgraph deploy

### Questions
- Why do the schemas get published both at build time as well as deploy? 
- what are persisted queries https://www.apollographql.com/docs/kotlin/advanced/persisted-queries

## Router and Coprocessor
had to change a few urls in this from changing the 
