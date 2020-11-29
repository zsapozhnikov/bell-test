<?php


namespace App\Service;


use App\Repository\BookRepository;

class BookSearchService
{
    private $bookRepository;

    public function __construct(BookRepository $bookRepository)
    {
        $this->bookRepository = $bookRepository;
    }

    public function handle($query)
    {
        return $this->bookRepository->findAllByName($query);
    }
}