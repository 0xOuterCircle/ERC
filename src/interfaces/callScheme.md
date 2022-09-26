### Proposal creation
```
Transaction[] pipeline
▽
IProposalRegistry.createProposal
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