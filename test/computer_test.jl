function computer_test()
    @testset "Computer" begin
        comp = current_computer();
        @test (comp.name == :LH)  &&  !is_remote(comp)  &&  run_local()

        compList = deepcopy(FilesLH.defaultCompList);
        compNew = Computer(name = :newComp, homeDir = "/Users/lutz/Documents",
            isRemote = false);

        # Add new computer that does not exist
        doReplace = add_computer(compNew, compList = compList);
        @test !doReplace
        # Add again, now it exists
        doReplace = add_computer(compNew, compList = compList);
        @test doReplace

        # Remove computer
        compExists = remove_computer(compNew, compList = compList);
        @test compExists
        # Remove again; it no longer exists
        compExists = remove_computer(compNew, compList = compList);
        @test !compExists
    end
end

@testset "Computer" begin
    computer_test();
end

# ------------