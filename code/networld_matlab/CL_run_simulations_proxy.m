function CL_run_simulations_proxy(nrep)

    disp(strcat('Simulation Job - Rep: ', num2str(nrep)))

    stream = RandStream('mt19937ar','seed',sum(100*clock));
    RandStream.setDefaultStream(stream);

    N = ;
    beta = ;
    T_Max = ;
    out_path = ;

    SCR_Run_Simulations(N, beta, T_Max, nrep, out_path)

end