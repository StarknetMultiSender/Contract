use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn transfer(
        ref self: TContractState, 
        from: ContractAddress, 
        to: ContractAddress, 
        amount: u256,
    );
}

#[starknet::interface]
trait IMultiSender<TContractState> {
    fn send(
        self: @TContractState,
        token: ContractAddress, 
        recipients: Array<ContractAddress>,
        amount: u256
    );
}
 
#[starknet::contract]
mod MulitSender {
    use starknet::get_caller_address;
    use super::IMultiSender;
    use super::ContractAddress;
    use super::IERC20DispatcherTrait;
    use super::IERC20Dispatcher;
    use option::OptionTrait;

    #[storage]
    struct Storage{}
    
    #[external(v0)]
    impl MulitSenderImpl of IMultiSender<ContractState> {
        fn send(
            self: @ContractState,
            token: ContractAddress, 
            recipients: Array<ContractAddress>,
            amount: u256
        ) {
            let contract_address = token;
            let dispatcher = IERC20Dispatcher { contract_address };
            let count: u256 = *@recipients.len().into();
            let average = amount / count;
            let mut recipients = recipients.clone();

            loop { 
                match recipients.pop_front() {
                    Option::Some(recipient) => {
                        dispatcher.transfer(get_caller_address(), recipient, average);
                    },
                    Option::None => { break; } ,
                }
            }
        }
    }
}