### Proposal creation
```
▽ for every of N IRouter in pipeline
[
    IRouterN.getTransaction ▷ Transaction
]
▽
Transaction[] pipeline ▷ Proposal
▽
IProposalRegistry.createProposal(Proposal)
```

### Proposal voting
```
IProposalRegistry.createProposal.vote
▽ for every Transaction N in pipeline
[
    IRouter.vote(decision, N, data, voteData)
    ▽
    IProposalRegistry.getProposal (optional)
    ▽
    updated Transaction in pipeline
]
```