# ERC стандарт для приложений , ориентированных на работу с DAO 

Автор: Ян <br/>
www.twitter.com/k0rean_rand0m <br/>
www.linkedin.com/in/ian-sosunov <br/>
www.twitter.com/0xOuterCircle

## Решение

Данный стандарт реализует механики, обеспечивающие взаимодействие приложений, ориентированных на децентрализованные 
сообщества. Основная идея сводится к голосованию участниками `DAO` за `Proposal`. При этом участники `DAO` 
представляются владельцами единого `Voting Power`, за управление которым отвечает `Governance токен`. В свою очередь 
`Proposal` является набором действий, которые должны быть выполнены `DdApp` (приложениями) при прохождении 
голосования за `Proposal`. Верхнеуровневые механики голосования за `Proposal` реализует `Proposal Registry`. 
Подразумевается, что такое верхнеуровневое голосование сводится к опциям "за"/"против" выполенния пайплайна действий,
описанного в `Proposal.actions`. Сложные механики голосования, такие как голосование за конкретные параметры, 
необходимые для передачи в `action` `DdApp`-а перекладываются на сами приложения (`DdApp`), что позволяет 
реализовать гибкие и не ограниченные в реализации приложения.

## Proposal и Action

```solidity
// Action - структура, содержащая информацию, необходимую для выполнения action приложения в случае прохождения Proposal
struct Action {
    // app - адрес контракта-приложения, реализующего интерфейс IDdApp
    IDdApp app;
    // signature - сигнатура функции, которая должна быть выполнена в формате someAction(type1, type2, ...)
    string signature;
    // params - параметры, передаваемые в app при голосовании пользователем "за" выполение пайплайна 
    //          и при выполнении action
    bytes params;
    // paramsPublic - параметры, передаваемые в app при голосовании пользователем "за" выполение пайплайна 
    //                и при выполнении action. Параметры, на которые голосующий может влиять
    bytes paramsPublic;
    // paramsPublicTypes - типы публичных параметров, на которые владелец Voting Power может влиять при голосовании "за"
    string[] paramsPublicTypes;
    // labels - имена для полей публичных параметров
    string[] labels;
}

// Proposal - пайплайн из Action, которые будут выполняться при прохождении Proposal
struct Proposal {
    // createdAt - block.timestamp создания Proposal
    uint256     createdAt;
    // ProposalCompleted - значение, отражающее статус Proposal
    bool        ProposalCompleted;
    // quorum - Voting Power "за"/"против" запуска пайплайна actions
    uint256[2]  quorum;
    // expiration - при block.timestamp >= createdAt + expiration голосование считается окончившемся
    uint256     expiration;
    // delay - задрежка выполнения actions после прохождения Proposal
    uint256     delay;
    // actions - массив Action, которые должны быть выполнены при прохождении Proposal.
    //           При голосовании за Proposal actions обходятся для перерасссчета Action.params
    Action[]    actions;
}
```

## IDdApp
Интерфейс децентрализованного приложения. Приложение должно содержать действия для запуска и вести перерассчет 
параметров при голосовании.

```solidity
interface IDdApp {
    // actionsTotal - общее количество действий, для которых может быть создан Action
    function actionsTotal() external view returns (uint256);
    
    // actionData - функция, возвращающая информацию об action приложения по actionId и начальные параметры
    function actionData(
        uint256 actionId
    ) external view returns (
        string memory actionSignature,  // Сигнатура, описанная в Action.signature
        bytes memory params, // Параметры, ожидаемые для передачи в IDdApp.voteFor и action при его выполнении
        string[] memory paramsPublicTypes,   // Типы параметров, описанные в Action.paramsPublicTypes
        string[] memory labels          // Названия публичных параметров, описанных в Action.labels
    );
    
    // voteFor - хук, вызываемый при голосовании в Proposal и созданный для перерассчета params в ходе голосования
    function voteFor(
        uint256 actionId, // actionId - id action приложения
        bool    voteFor,  // voteFor - флаг, отражающий голос "за" или "против" прохождения Proposal 
        uint256 votedVp,  // votedVp - Voting Power, с которым был отдан голос
        uint256 totalVp,  // totalVp - суммарный Voting Power всех держателей Voting Power
        bytes memory params,  // params - параметры Action.params до отдачи голоса
        bytes memory paramsPublic,  // paramsPublic - параметры Action.paramsPublic до отдачи голоса
        bytes memory paramsVoted  // paramsVoted - значения Action.paramsPublic, переданные с голосом
    ) external returns (
        bytes memory updParams,  // updParams - значения Action.params после прохождения голоса
        bytes memory updParamsPublic  // updParamsPublic - значения Action.paramsPublic после прохождения голоса
    );
}
```

## IProposalRegistry
Интерфейс контракта, хранящего `Proposal`, ответственного за верхнеуровневое голосование и выполнение `Proposal` при 
его прохождении.

```solidity
interface IProposalRegistry {
    
    //// Getters ////
    
    // totalProposalsFor - возвращает общее количество зарегистрированных Proposal для IGovernance
    function totalProposalsFor(IGovernance governance) external returns (uint256);
    // getProposal - возвращает Proposal для IGovernance по id Proposal
    function getProposal(IGovernance governance, uint256 proposalId) external view returns (Proposal memory proposal);

    //// Setters ////
    // msg.sender для следующих функций должен быть IGovernance
    
    // registerProposal - регистрирует Proposal для IGovernance и возвращает id нового Proposal
    function registerProposal(Proposal memory proposal) external returns (uint256 id);
    // executeProposal - выполняет Proposal по id Proposal
    //                   возвращает флаг success = true при успешном выполнении Proposal.actions
    function executeProposal(uint256 proposalId) external returns (bool success);
    // vote - позволяет проголосовать за Proposal. Принимает id Proposal, флаг voteFor и Voting Power голоса
    function vote(uint256 proposalId, bool voteFor, uint256 vp) external;
}
```

## IGovernance
Интерфейс контракта, реализующего Governance токен.

```solidity

// GovernanceSettings - настройки группы владельцев Voting Power
    struct GovernanceSettings {
        // proposalCreationThreshold - Voting Power, необходимый для создания Proposal
        uint256 proposalCreationThreshold;
        // minQuorum - минимальный Proposal.quorum, который должен быть набран за опцию для прохождения Proposal
        uint256 minQuorum;
        // proposalExpiration - значение, которое будет установлено для Proposal.expiration
        uint256 proposalExpiration;
        // proposalDelay - значение, которое будет установлено для Proposal.delay
        uint256 proposalDelay;
    }

interface IGovernance is IDdApp {
    // В функциях этого интерфейса фигурируют id, которые необходимы для реализации IGovernance, 
    // наследуемого от IERC1155

    //// Getters ////

    // parent - родительский провайдер Voting Power для IGovernance
    function parent(uint256 id) external view returns (address vpProvider, uint256 id_);
    // votingPower - возвращает Voting Power для участника member
    function votingPower(address member, uint256 id) external view returns (uint256);
    // totalVotingPower - суммарный Voting Power всех участников сообщества
    function totalVotingPower(uint256 id) external view returns (uint256);
    // governanceSettings - возвращает настройки для сообщества
    function governanceSettings(uint256 id) external view returns (GovernanceSettings memory);
    // totalTrustedRegistries - возвращает общее число доверенных IProposalRegistry
    function totalTrustedRegistries() external view returns (uint256);
    // trustedRegistry - возвращает адрес доверенного IProposalRegistry по идентификатору
    function trustedRegistry(uint256 registryId) external view returns (IProposalRegistry);

    //// Managing Settings ////

    // updateSettings - позволяет обновлять настройки GovernanceSettings для сообщества
    //                  является DdApp action
    function updateSettings(GovernanceSettings memory settings, uint256 id) external;
    // addTrustedRegistry - позволяет зарегистрировать новый доверенный IProposalRegistry
    //                      является DdApp action
    function addTrustedRegistry(IProposalRegistry memory registry) external;
    // removeTrustedRegistry - позволяет удалить доверенный IProposalRegistry
    //                         является DdApp action
    function removeTrustedRegistry(IProposalRegistry memory registry) external;

    //// Managing Voting Power ////
    // stakeFor - позволяет перевести balance в Voting Power
    function stakeFor(address staker, address delegatee, uint256 id, uint256 amount) external;
    // unstakeFor - позволяет перевести Voting Power в balance
    function unstakeFor(address staker, address receiver, uint256 id, uint256 amount) external;

    //// Proposals management ////
    // Следующие функции взаимодействуют с IProposalRegistry

    // registerProposal - регистрирует новый Proposal в доверенном IProposalRegistry по его id
    function registerProposal(uint256 registryId, Proposal memory proposal) external returns (uint256 id);
    // registerProposal - выполняет Proposal в доверенном IProposalRegistry по его id
    function executeProposal(uint256 registryId, uint256 proposalId) external returns (bool success);
    // vote - позволяет проголосовать за Proposal
    function vote(uint256 registryId, uint256 proposalId, uint256 vp) external;

    //// Hooks ////

    // proposalCompleted - хук, к которому обращается IProposalRegistry после прохождения/отклонения Proposal
    function proposalCompleted(uint256 proposalId) external;
}
```